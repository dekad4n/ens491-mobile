import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';

class AuctionPage extends StatefulWidget {
  final Map<dynamic, dynamic>? item;
  final Event? event;
  final UserProvider? userProvider;
  final MetamaskProvider? metamaskProvider;

  const AuctionPage({
    super.key,
    this.item,
    this.event,
    this.userProvider,
    this.metamaskProvider,
  });

  @override
  State<AuctionPage> createState() => _AuctionPageState();
}

class _AuctionPageState extends State<AuctionPage> {
  List<dynamic> auctions = [];
  bool _isLoading = true;

  double _startPrice = 0;
  double _bid = 0;

  bool _isHighestBidder = true;

  eventPreviewContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.event!.title!,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
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
                widget.event!.coverImageURL!,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  priceContainer(double input, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          width: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "MATIC  ",
                    style: TextStyle(
                      fontSize: 16,
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
                            input = double.parse(value);
                          });
                        } else {
                          setState(() {
                            input = 0;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '';
                        } else {
                          setState(() {
                            input = double.parse(value);
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

  highestBidSection() {
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(0xFFB9A6E0).withOpacity(0.1),
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "You are the highest bidderx!",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "There are 5 bids on this item.",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  "Highest Bid:",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Divider(thickness: 1),
                Text(
                  "MATIC  3.49",
                  style: TextStyle(
                      color: Color.fromARGB(255, 165, 134, 227),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ]),
    );
  }

  createAuctionSection() {
    return Column(
      children: [
        Text(
          "You haven't created an auction for this item yet.",
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 10),
        priceContainer(_startPrice, "Starting Price"),
        SizedBox(height: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 150,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color(0xFF050A31),
              boxShadow: [
                BoxShadow(
                  offset: Offset(-2, 2),
                  blurRadius: 4,
                  spreadRadius: 2,
                  color: Color.fromRGBO(5, 10, 49, 0.1),
                ),
              ],
            ),
            child: Center(
                child: Text("Create Auction",
                    style: TextStyle(color: Colors.white))),
          ),
          onTap: () {
            print("create auction");
          },
        ),
      ],
    );
  }

  stopAuctionSection() {}

  ticketOwnerSection() {
    return createAuctionSection();
  }

  // SizedBox(height: 5),
  //       Text(
  //         "You haven't bid on this item yet.",
  //         style: TextStyle(color: Colors.grey),
  //       ),

  placeBidSection() {
    return Container(
        padding: EdgeInsets.all(12),
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(0xFFB9A6E0).withOpacity(0.1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                priceContainer(_bid, "Your Bid:"),
                SizedBox(width: 10),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFF050A31),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(-2, 2),
                          blurRadius: 4,
                          spreadRadius: 2,
                          color: Color.fromRGBO(5, 10, 49, 0.1),
                        ),
                      ],
                    ),
                    child: Center(
                        child: Text("Place Bid",
                            style: TextStyle(color: Colors.white))),
                  ),
                  onTap: () {
                    print("bid");
                  },
                ),
              ],
            ),
          ],
        ));
  }

  claimSection() {
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(0xFFB9A6E0).withOpacity(0.1),
      ),
      child: Column(
        children: [
          Text(
            "You have bid on this item:",
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MATIC  7.25",
                style: TextStyle(
                    color: Color.fromARGB(255, 165, 134, 227),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFF050A31),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(-2, 2),
                        blurRadius: 4,
                        spreadRadius: 2,
                        color: Color.fromRGBO(5, 10, 49, 0.1),
                      ),
                    ],
                  ),
                  child: Center(
                      child:
                          Text("Claim", style: TextStyle(color: Colors.white))),
                ),
                onTap: () {
                  print("claim");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  bidderSection() {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          highestBidSection(),
          SizedBox(height: 20),
          placeBidSection(),
          SizedBox(height: 20),
          claimSection(),
        ],
      ),
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
          "Auction",
          style: TextStyle(
            color: Color(0xff050a31),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                eventPreviewContainer(),
                SizedBox(height: 10),
                widget.userProvider!.user!.publicAddress ==
                        widget.item!["ticketOwner"]!
                    ? ticketOwnerSection()
                    : bidderSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
