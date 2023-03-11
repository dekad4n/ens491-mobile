import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:tickrypt/services/ticket.dart';
import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateTicket extends StatefulWidget {
  final Event event;
  final UserProvider userProvider;
  final MetamaskProvider metamaskProvider;

  const CreateTicket(
      {Key? key,
      required this.event,
      required this.userProvider,
      required this.metamaskProvider})
      : super(key: key);

  @override
  State<CreateTicket> createState() => _CreateTicketState();
}

class _CreateTicketState extends State<CreateTicket> {
  double? _price;
  int? _quantity;

  final alchemy = Alchemy();

  TicketService ticketService = TicketService();

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

  priceContainer() {
    return Container(
      padding: EdgeInsets.all(8),
      height: 90,
      width: 100,
      decoration: BoxDecoration(
        border:
            Border.all(color: _price != null ? Colors.deepPurple : Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Price",
            style: TextStyle(
                color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                "ETH  ",
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

  quantityContainer() {
    return Container(
      padding: EdgeInsets.all(8),
      height: 90,
      width: 100,
      decoration: BoxDecoration(
        border:
            Border.all(color: _price != null ? Colors.deepPurple : Colors.grey),
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
                    border: null,
                  ),
                  // The validator receives the text that the user has entered.
                  keyboardType: TextInputType.number,
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

  confirmButton(metamaskProvider) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 70,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff050a31), // Background color
                elevation: 0,
                side: BorderSide(color: Colors.deepPurple),
              ),
              onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );

                var mintResult = await ticketService.mint(
                  auth: widget.userProvider.token,
                  eventId: widget.event.integerId,
                  amount: 5, //_quantity
                );

                print("xxx");
                alchemy.init(
                  httpRpcUrl:
                      "https://polygon-mumbai.g.alchemy.com/v2/jq6Um8Vdb_j-F0vwzpqBjvjHiz3-v5wy",
                  wsRpcUrl:
                      "wss://polygon-mumbai.g.alchemy.com/v2/jq6Um8Vdb_j-F0vwzpqBjvjHiz3-v5wy",
                  verbose: true,
                );

                List<dynamic> params = [
                  {
                    "from": mintResult["from"],
                    "to": mintResult["to"],
                    "data": mintResult["data"],
                  }
                ];

                String method = "eth_sendTransaction";

                await launchUrl(
                    Uri.parse(metamaskProvider.connector.session.toUri()),
                    mode: LaunchMode.externalApplication);

                final signature =
                    await metamaskProvider.connector.sendCustomRequest(
                  method: method,
                  params: params,
                );

                print("signature:" + signature);

                try {
                  print("burda");
                } catch (e) {
                  print(e);
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
          "Create Ticket",
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
                    priceContainer(),
                    quantityContainer(),
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
