import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:tickrypt/services/auction.dart';
import 'package:url_launcher/url_launcher.dart';

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
  AuctionService auctionService = AuctionService();

  final alchemy = Alchemy();

  List<dynamic> auctions = [];
  bool _isLoading = false;

  double _startPrice = 0;
  double _bid = 0;
  int _timeSeconds = 0;

  bool _isHighestBidder = true;

  bool _alreadyAucted = false;

  void checkAlreadyAucted() async {
    setState(() {
      _isLoading = true;
    });

    // Fetch all auction items at once
    List<dynamic> fetchedAuctions =
        await auctionService.getOngoingAuctions(widget.event!.integerId);

    // Check if this ticket's id exists in the fetched auctions
    fetchedAuctions.forEach((auction) {
      if (auction["ticketId"] == widget.item!["tokenID"]) {
        setState(() {
          _alreadyAucted = true;
        });
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

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
        SizedBox(height: 5),
        Text(
          "Ticket id: ${widget.item!["tokenID"]}",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18,
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

  priceContainer(String varName) {
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
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value != null && value != "") {
                          if (varName == "price") {
                            setState(() {
                              _startPrice = double.parse(value);
                            });
                          } else if (varName == "bid") {
                            setState(() {
                              _bid = double.parse(value);
                            });
                          }
                        } else {
                          if (varName == "price") {
                            setState(() {
                              _startPrice = 0;
                            });
                          } else if (varName == "bid") {
                            setState(() {
                              _bid = 0;
                            });
                          }
                        }
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

  timeSecondsContainer() {
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
                    "Days ",
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
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value != null && value != "") {
                          setState(() {
                            _timeSeconds = int.parse(value) * 24 * 60 * 60;
                          });
                        } else {
                          setState(() {
                            _timeSeconds = 0;
                          });
                        }
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
                  "There are 5 bids on this item.",
                  style: TextStyle(color: Color(0xFF050A31)),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "You are the highest bidder!",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 15,
                  ),
                ),
                Divider(thickness: 1),
                Text(
                  "Highest Bid:",
                  style: TextStyle(
                    color: Color(0xFF050A31),
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
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

  // BIDDER SECTION  ---------------------------------------------------------

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
                priceContainer("bid"),
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
            "You have total bid on this item:",
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

  // TICKET OWNER ----------------------------------------------
  startAuctionSection() {
    return Container(
      padding: EdgeInsets.all(20),
      // width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color.fromARGB(255, 136, 210, 135).withOpacity(0.1),
      ),
      child: Column(
        children: [
          Text(
            "Start an auction by setting a price and lifetime:",
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(height: 10),
          priceContainer("price"),
          timeSecondsContainer(),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Start Auction",
                      style:
                          TextStyle(color: Color.fromARGB(255, 177, 254, 186))),
                  Icon(CupertinoIcons.check_mark_circled_solid,
                      color: Color.fromARGB(255, 177, 254, 186)),
                ],
              ),
            ),
            onTap: () async {
              try {
                dynamic transactionParameters =
                    await auctionService.createBidItem(
                  widget.item!["tokenID"],
                  widget.event!.integerId,
                  _startPrice,
                  _timeSeconds,
                  widget.userProvider!.token,
                );

                print(
                    "transcationParamters:" + transactionParameters.toString());

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

                final signature =
                    await widget.metamaskProvider!.connector.sendCustomRequest(
                  method: method,
                  params: params,
                );

                print("signature:" + signature);
              } catch (e) {
                print(e.toString() + " ERROR while /sell");
              }
            },
          ),
        ],
      ),
    );
  }

  stopAuctionSection() {
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color.fromARGB(255, 255, 102, 102).withOpacity(0.1),
      ),
      child: Column(
        children: [
          Text(
            "There is an active auction for this item.",
            style: TextStyle(color: Colors.black),
          ),
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
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Stop Auction",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 178, 178),
                      )),
                  Icon(Icons.cancel, color: Color.fromARGB(255, 255, 178, 178)),
                ],
              )),
            ),
            onTap: () {
              print("stop auction");
            },
          ),
        ],
      ),
    );
  }

  ticketOwnerSection() {
    if (_alreadyAucted) {
      return Column(
        children: [
          highestBidSection(),
          SizedBox(height: 20),
          stopAuctionSection(),
        ],
      );
    } else {
      return Column(
        children: [
          startAuctionSection(),
        ],
      );
    }
  }
  //------------------------------------------------------------------

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkAlreadyAucted();
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
          "Ticket Auction",
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
                _isLoading
                    ? Center(
                        child: Text("Loading..."),
                      )
                    : widget.userProvider!.user!.publicAddress !=
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
