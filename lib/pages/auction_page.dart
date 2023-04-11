import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  bool _isHighestBidder = false;

  bool _alreadyAucted = false;
  Map _alreadyAuctedItem = {};

  List _prevBids = [];

  double _myTotalPrevBids = 0;

  late DateTime _endAt;

  Future<void> fetchAuctionDetails() async {
    setState(() {
      _alreadyAucted = false;
      _alreadyAuctedItem = {};
      _isHighestBidder = false;
      _prevBids = [];
      _myTotalPrevBids = 0;
      _endAt = DateTime.now();

      _isLoading = true;
    });

    // Fetch all auction items at once
    List<dynamic> fetchedAuctions =
        await auctionService.getAuctionsByEventId(widget.event!.integerId);

    // Check if this ticket's id exists in the fetched auctions
    for (var auction in fetchedAuctions) {
      if (auction["ticketId"] == widget.item!["tokenID"]) {
        // If it is already aucted, fetch auction info then
        // Map auctionInfo =
        //     await auctionService.getAuctionInfo(auction["auctionId"]);

        // print(auctionInfo);

        // Parse endAt to DateTime (convert to UTC then to user's local time zone)
        var endAt = DateTime.fromMillisecondsSinceEpoch(
                int.parse(auction["endAt"]) * 1000)
            .toUtc()
            .toLocal();

        // And fetch all previous bids
        List prevBids = await auctionService.listPrevBids(
            auction["auctionId"], widget.userProvider!.token!);

        double myTotalPrevBids = 0;
        // Calculate my total prev bids
        for (var bidItem in prevBids) {
          print(bidItem);
          if (bidItem["bidder"].toLowerCase() ==
                  widget.userProvider!.user!.publicAddress.toLowerCase() &&
              bidItem["isBack"] == false) {
            myTotalPrevBids += double.parse(bidItem["bid"]);
          }
        }

        // Don't forget to add the amount of the highest bid, if you are current highest bidder
        if (auction["highestBidder"].toLowerCase() ==
            widget.userProvider!.user!.publicAddress.toLowerCase()) {
          myTotalPrevBids += auction["highestBid"];
        }

        setState(() {
          _alreadyAucted = true;
          _alreadyAuctedItem = auction;
          _endAt = endAt;

          _prevBids = prevBids;

          _myTotalPrevBids = myTotalPrevBids;

          if ((auction["highestBidder"].toLowerCase() ==
                  widget.userProvider!.user!.publicAddress.toLowerCase()) &&
              prevBids.length > 0) {
            _isHighestBidder = true;
          }

          _isLoading = false;
        });

        return;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  eventPreviewContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
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

  priceInputContainer(String varName) {
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

  timeInputContainer() {
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
                _prevBids.length > 0
                    ? Text(
                        "There are ${_prevBids.length} bids on this item.",
                        style: TextStyle(color: Color(0xFF050A31)),
                      )
                    : Text(
                        "There is no bid on this item.",
                        style: TextStyle(color: Color(0xFF050A31)),
                      ),
                SizedBox(
                  height: 10,
                ),
                _isHighestBidder
                    ? Text(
                        "You are the highest bidder!",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 15,
                        ),
                      )
                    : SizedBox(),
                Divider(thickness: 1),
                _prevBids.length > 0
                    ? Text(
                        "Highest Bid",
                        style: TextStyle(
                          color: Color(0xFF050A31),
                          fontSize: 18,
                        ),
                      )
                    : Text(
                        "Start Price",
                        style: TextStyle(
                          color: Color(0xFF050A31),
                          fontSize: 18,
                        ),
                      ),
                SizedBox(height: 5),
                Text(
                  "MATIC  ${_alreadyAuctedItem['highestBid']}",
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

  endDateSection() {
    int year = _endAt.year;
    int month = _endAt.month;
    int day = _endAt.day;

    int hour = _endAt.hour;
    int minute = _endAt.minute;

    if (_endAt.isBefore(DateTime.now())) {
      return Container(
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color.fromARGB(255, 185, 244, 178).withOpacity(0.3),
          ),
          child: Center(
              child: Column(
            children: [
              Text(
                "This auction is expired",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                "Press the button below to complete transactions",
                textAlign: TextAlign.center,
              ),
              Divider(thickness: 1),
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
                        Text("Finish Auction",
                            style: TextStyle(
                                color: Color.fromARGB(255, 177, 254, 186))),
                        Icon(CupertinoIcons.check_mark_circled_solid,
                            color: Color.fromARGB(255, 177, 254, 186)),
                      ],
                    ),
                  ),
                ),
                onTap: () async {
                  try {
                    dynamic transactionParameters =
                        await auctionService.finishBid(
                      _alreadyAuctedItem['auctionId'],
                      widget.userProvider!.token,
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
                    );

                    print("signature:" + signature);
                  } catch (e) {
                    print(e.toString() + " ERROR while /stop-auction");
                  }
                },
              ),
            ],
          )));
    } else {
      return Container(
        padding: EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color.fromARGB(255, 185, 244, 178).withOpacity(0.3),
        ),
        child: Center(
            child: Column(
          children: [
            Text("This auction will end at"),
            Divider(thickness: 1),
            Text(
              "$year/$month/$day   $hour:$minute",
              style: TextStyle(
                color: Color(0xFF050A31),
                fontSize: 18,
              ),
            ),
          ],
        )),
      );
    }
  }

  // IF BIDDER, RENDER THESE  ---------------------------------------------------------

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
                priceInputContainer("bid"),
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
                  onTap: () async {
                    if (_alreadyAuctedItem["highestBid"] > _bid) {
                      // Show error saying that input must be greater than highest bid
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Invalid Bid!"),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: const <Widget>[
                                  Text(
                                      'Your bid must be greater than the highest bid!'),
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
                      try {
                        dynamic transactionParameters =
                            await auctionService.placeBid(
                          _alreadyAuctedItem['auctionId'],
                          _bid,
                          widget.userProvider!.token,
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
                            "value": transactionParameters["value"],
                          }
                        ];

                        String method = "eth_sendTransaction";

                        await launchUrl(
                            Uri.parse(widget.metamaskProvider!.connector.session
                                .toUri()),
                            mode: LaunchMode.externalApplication);

                        final signature = await widget
                            .metamaskProvider!.connector
                            .sendCustomRequest(
                          method: method,
                          params: params,
                        );

                        print("signature:" + signature);
                      } catch (e) {
                        print(e.toString() + " ERROR while /bid");
                      }
                    }
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
            "You have total bid:",
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MATIC  ${_myTotalPrevBids}",
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
                    color: _myTotalPrevBids > 0 && !_isHighestBidder
                        ? Color(0xFF050A31)
                        : Colors.grey,
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
                onTap: () async {
                  if (_myTotalPrevBids > 0 && !_isHighestBidder) {
                    try {
                      dynamic transactionParameters =
                          await auctionService.paybackPrevBids(
                        _alreadyAuctedItem['auctionId'],
                        widget.userProvider!.token,
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
                    } catch (e) {
                      print(e.toString() + " ERROR while /payback-prev-bids");
                    }
                  }
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
          endDateSection(),
          SizedBox(height: 20),
          highestBidSection(),
          SizedBox(height: 20),
          placeBidSection(),
          SizedBox(height: 20),
          claimSection(),
        ],
      ),
    );
  }

  // IF TICKET OWNER, RENDER THESE ----------------------------------------------
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
          priceInputContainer("price"),
          timeInputContainer(),
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
                print(e.toString() + " ERROR while /create-bid-item");
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
            onTap: () async {
              try {
                dynamic transactionParameters =
                    await auctionService.stopAuction(
                  _alreadyAuctedItem['auctionId'],
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
                print(e.toString() + " ERROR while /stop-auction");
              }
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
          endDateSection(),
          SizedBox(height: 20),
          highestBidSection(),
          SizedBox(height: 20),
          _endAt.isAfter(DateTime.now()) ? stopAuctionSection() : SizedBox(),
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
    fetchAuctionDetails();
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
        title: Column(
          children: [
            Text(
              "Ticket Auction",
              style: TextStyle(
                color: Color(0xff050a31),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            _isLoading
                ? SizedBox()
                : (_alreadyAucted
                    ? (_endAt.compareTo(DateTime.now()) > 0)
                        ? Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text("Active"),
                          )
                        : Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text("Expired"),
                          )
                    : Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 175, 137, 76),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child:
                            Text("No Auction", style: TextStyle(fontSize: 14)),
                      ))
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await fetchAuctionDetails();
          },
          child: ListView(children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    eventPreviewContainer(),
                    SizedBox(height: 10),
                    _isLoading
                        ? Center(
                            child: Text("Loading..."),
                          )
                        : widget.userProvider!.user!.publicAddress
                                    .toLowerCase() ==
                                widget.item!["ticketOwner"].toLowerCase()
                            ? ticketOwnerSection()
                            : bidderSection(),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
