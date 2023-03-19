import 'package:flutter/material.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:tickrypt/services/market.dart';
import 'package:tickrypt/services/ticket.dart';
import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:url_launcher/url_launcher.dart';

class ResellTicketPage extends StatefulWidget {
  final Event event;
  final UserProvider userProvider;
  final MetamaskProvider metamaskProvider;
  final List<dynamic> myOwnItems;

  const ResellTicketPage({
    Key? key,
    required this.event,
    required this.userProvider,
    required this.metamaskProvider,
    required this.myOwnItems,
  }) : super(key: key);

  @override
  State<ResellTicketPage> createState() => ResellTicketPageState();
}

class ResellTicketPageState extends State<ResellTicketPage> {
  int _quantity = 0;
  double _price = 0.0;

  List<dynamic> _transferableIds = [];

  final alchemy = Alchemy();

  TicketService ticketService = TicketService();
  MarketService marketService = MarketService();

  Future<List<dynamic>> getTransferableIds() async {
    List<dynamic> transferableIds = await marketService.getTransferableIds(
      widget.userProvider.token,
      widget.event.integerId,
      widget.userProvider.user!.publicAddress,
    );
    setState(() {
      _transferableIds = transferableIds;
    });
    return transferableIds;
  }

  eventPreviewContainer() {
    return Column(
      children: [
        Text(
          "Event Preview",
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

  yourTicketSection() {
    return Container(
        padding: EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(0xFFB9A6E0).withOpacity(0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Ticket Status",
              style: TextStyle(
                  color: Color(0xFF050A31),
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            Divider(thickness: 1),
            Text(
              "You own:",
              style: TextStyle(
                  color: Color(0xFF050A31),
                  fontSize: 18,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "General Admission",
                  style: TextStyle(
                      color: Color(0xFF050A31),
                      fontSize: 18,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  "x ${widget.myOwnItems.length}",
                  style: TextStyle(
                      color: Color(0xFF050A31),
                      fontSize: 18,
                      fontWeight: FontWeight.w300),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            FutureBuilder(
                future: getTransferableIds(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      "Only ${snapshot.data!.length}/${widget.myOwnItems.length} are transferable!",
                      style: TextStyle(color: Colors.red[900]),
                    );
                  } else {
                    return Text(
                      "Loading transferability status of tickets...",
                      style: TextStyle(color: Colors.red[900]),
                    );
                  }
                }),
          ],
        ));
  }

  quantityContainer() {
    return Container(
      padding: EdgeInsets.all(8),
      height: 90,
      width: 100,
      decoration: BoxDecoration(
        border:
            Border.all(color: _quantity != 0 ? Colors.deepPurple : Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quantity",
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
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.grey),
                    border: null,
                    hintText: "max. ${_transferableIds.length.toString()}",
                  ),
                  // The validator receives the text that the user has entered.
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value != null && value != "") {
                      setState(() {
                        _quantity = int.parse(value);
                      });
                    } else {
                      setState(() {
                        _quantity = 0;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '';
                    } else {
                      setState(() {
                        _quantity = int.parse(value);
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          height: 90,
          width: 150,
          decoration: BoxDecoration(
            border: Border.all(
                color: _price != 0 ? Colors.deepPurple : Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Price per Ticket",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
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
                        } else {
                          setState(() {
                            _price = 0;
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
        ),
      ],
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
                  if (_price > 0 && _quantity > 0) {
                    if (_quantity > _transferableIds.length) {
                      // Warn if user enters quantity larget than how many they own
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Invalid Quantity!"),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: const <Widget>[
                                  Text(
                                      'You cannot give quantity more than what you own.'),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      dynamic transactionParameters =
                          await marketService.resellMultiple(
                        widget.userProvider!.token,
                        _price,
                        _transferableIds.sublist(0, _quantity - 1),
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
                          Uri.parse(widget.metamaskProvider!.connector.session
                              .toUri()),
                          mode: LaunchMode.externalApplication);

                      final signature = await widget.metamaskProvider!.connector
                          .sendCustomRequest(
                        method: method,
                        params: params,
                      );

                      print("signature:" + signature);

                      Navigator.pop(context);
                    }
                  }
                } catch (e) {
                  print(e.toString() + " ERROR while /resell");
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
          "Resell Your Tickets",
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

                yourTicketSection(),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    quantityContainer(),
                    priceContainer(),
                  ],
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
