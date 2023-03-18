import 'package:flutter/material.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:tickrypt/services/market.dart';
import 'package:tickrypt/services/ticket.dart';
import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:url_launcher/url_launcher.dart';

class SellTicketPage extends StatefulWidget {
  final Event event;
  final List<dynamic> mintedTicketTokenIds;
  final UserProvider userProvider;
  final MetamaskProvider metamaskProvider;

  const SellTicketPage(
      {Key? key,
      required this.event,
      required this.mintedTicketTokenIds,
      required this.userProvider,
      required this.metamaskProvider})
      : super(key: key);

  @override
  State<SellTicketPage> createState() => SellTicketPageState();
}

class SellTicketPageState extends State<SellTicketPage> {
  double _price = 0.0;
  int _transferRight = 0;
  double _comission = 0;

  List<dynamic> marketItemsAll = [];

  final alchemy = Alchemy();

  TicketService ticketService = TicketService();
  MarketService marketService = MarketService();

  eventPreviewContainer() {
    return Column(
      children: [
        Text(
          "Preview",
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 10),
        Container(
          width: 250,
          height: 250,
          child: Container(
            height: 120,
            width: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                widget.event.coverImageURL!,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.event.title!,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20),
              Text(
                widget.event.description!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 20),
              Text(
                widget.event.category!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Start",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_month),
                      Text(
                        widget.event.startDate!,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.access_time),
                      Text(
                        widget.event.startTime!,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "End",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_month),
                      Text(
                        widget.event.endDate!,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.access_time),
                      Text(
                        widget.event.endTime!,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  transfersContainer() {
    return Container(
      padding: EdgeInsets.all(8),
      height: 100,
      width: 150,
      decoration: BoxDecoration(
        border: Border.all(
            color: _transferRight != 0 ? Colors.deepPurple : Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How Many Transfers Do You Allow?",
            style: TextStyle(
                color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(border: null, hintText: "e.g. 3"),
                  // The validator receives the text that the user has entered.
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value != null && value != "") {
                      setState(() {
                        _transferRight = int.parse(value);
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '';
                    } else {
                      setState(() {
                        _transferRight = int.parse(value);
                      });
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  priceContainer() {
    return Container(
      padding: EdgeInsets.all(8),
      height: 90,
      width: 150,
      decoration: BoxDecoration(
        border:
            Border.all(color: _price != 0 ? Colors.deepPurple : Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Price per Ticket",
            style: TextStyle(
                color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                "MATIC  ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: null,
                  ),
                  // The validator receives the text that the user has entered.
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value != null && value != "") {
                      setState(() {
                        _price = double.parse(value);
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '';
                    } else {
                      setState(() {
                        _price = double.parse(value);
                      });
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  comissionContainer() {
    return Container(
      padding: EdgeInsets.all(8),
      height: 100,
      width: 150,
      decoration: BoxDecoration(
        border: Border.all(
            color: _comission != 0 ? Colors.deepPurple : Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Comission per Sale",
            style: TextStyle(
                color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                "%  ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: null,
                    hintText: "e.g. 12.5",
                  ),
                  // The validator receives the text that the user has entered.
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value != null && value != "") {
                      setState(() {
                        _comission = double.parse(value);
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '';
                    } else {
                      setState(() {
                        _comission = double.parse(value);
                      });
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  confirmButton(metamaskProvider) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 70,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _price != 0
                    ? Color(0xff050a31)
                    : Colors.grey, // Background color
                elevation: 0,
              ),
              onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.
                try {
                  dynamic transactionParameters = await marketService.sell(
                    widget.userProvider!.token,
                    widget.event.integerId,
                    _price,
                    widget.mintedTicketTokenIds.length,
                    _transferRight,
                  );

                  print("transcationParamters:" +
                      transactionParameters.toString());

                  alchemy.init(
                    httpRpcUrl:
                        "https://polygon-mumbai.g.alchemy.com/v2/jq6Um8Vdb_j-F0vwzpqBjvjHiz3-v5wy",
                    wsRpcUrl:
                        "wss://polygon-mumbai.g.alchemy.com/v2/jq6Um8Vdb_j-F0vwzpqBjvjHiz3-v5wy",
                    verbose: true,
                  );

                  List<dynamic> params = [
                    {
                      "from": transactionParameters["from"],
                      "to": transactionParameters["to"],
                      "data": transactionParameters["data"],
                    }
                  ];

                  String method = "eth_sendTransaction";

                  await launchUrl(
                      Uri.parse(
                          widget.metamaskProvider!.connector.session.toUri()),
                      mode: LaunchMode.externalApplication);

                  final signature = await widget.metamaskProvider!.connector
                      .sendCustomRequest(
                          method: method,
                          params: params,
                          topic:
                              "List ${widget.mintedTicketTokenIds.length} Tickets On Market!");

                  print("signature:" + signature);

                  Navigator.pop(context);
                } catch (e) {
                  print(e.toString() + " ERROR while /sell");
                }
              },
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shadowColor: null,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          iconSize: 30,
          color: Color(0xff050a31),
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Sell Ticket",
          style: TextStyle(
            color: Color(0xff050a31),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                eventPreviewContainer(),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    transfersContainer(),
                    comissionContainer(),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    priceContainer(),
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Tickript will charge 15% comission for this operation: Listing items in the market",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(height: 20),
                confirmButton(widget.metamaskProvider),
                // ElevatedButton(
                //     onPressed: () async {
                //       await ticketService.getTicketDetails(ticketToken: 4);
                //     },
                //     child: Text("Get Ticket NFT Metadata"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
