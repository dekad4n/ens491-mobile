import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tickrypt/models/user_model.dart';
import 'package:tickrypt/pages/resell_ticket_page.dart';
import 'package:tickrypt/pages/scan_page.dart';
import 'package:tickrypt/pages/sell_ticket_page.dart';
import 'package:tickrypt/pages/mint_ticket_page.dart';
import 'package:tickrypt/pages/set_ticket_controller.dart';
import 'package:tickrypt/pages/your_tickets_page.dart';
import 'package:tickrypt/pages/transfer_page.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:tickrypt/services/event.dart';
import 'package:tickrypt/services/market.dart';
import 'package:tickrypt/services/user.dart';
import 'package:tickrypt/widgets/atoms/buttons/backButtonWhite.dart';
import 'package:url_launcher/url_launcher.dart';

class EventPage extends StatefulWidget {
  final dynamic event;
  final UserProvider? userProvider;
  final MetamaskProvider? metamaskProvider;

  const EventPage(
      {super.key, this.event, this.userProvider, this.metamaskProvider});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  final alchemy = Alchemy();

  UserService userService = UserService();
  EventService eventService = EventService();
  MarketService marketService = MarketService();

  late Future<User> owner;

  List<dynamic> _mintedTicketTokenIds = [];
  List<dynamic> _marketItemsAll = [];
  List<dynamic> _marketItemsSold = [];
  List<dynamic> _marketItemsOnSale = [];

  List<dynamic> _myItemsOnSale = [];
  List<dynamic> _myOwnItems = [];

  bool _isLoading = true;

  int mySortComparison(dynamic item1, dynamic item2) {
    if (item1["price"] < item2["price"]) {
      return -1;
    } else if (item1["price"] > item2["price"]) {
      return 1;
    } else {
      return 0;
    }
  }

  @override
  void initState() {
    refreshTicketStatus();

    super.initState();
  }

  void getOwner() {
    setState(() {
      owner = userService.getNonce(widget.event.owner);
    });
  }

  Future<List<dynamic>> getMintedEventTicketTokens() async {
    List<dynamic> mintedEventTicketTokens =
        await eventService.getMintedEventTicketIds(widget.event.integerId);

    return mintedEventTicketTokens;
  }

  Future<List<dynamic>> getMarketItemsAll() async {
    List<dynamic> marketItemsAll =
        await marketService.getMarketItemsAllByEventId(widget.event.integerId);

    marketItemsAll.sort(mySortComparison);

    return marketItemsAll;
  }

  void refreshTicketStatus() {
    setState(() {
      _isLoading = true;
    });
    getMintedEventTicketTokens().then((value) {
      setState(() {
        _mintedTicketTokenIds = value;
      });

      getMarketItemsAll().then((value) {
        List<dynamic> marketItemsAll = value;
        List<dynamic> marketItemsSold = [];
        List<dynamic> marketItemsOnSale = [];

        List<dynamic> myOwnItems = [];
        List<dynamic> myItemsOnSale = [];

        for (dynamic marketItem in marketItemsAll) {
          if (RegExp(r'^0x0+$').hasMatch(marketItem["seller"]) &&
              marketItem["sold"]) {
            // If seller address is zeroAddress (0x000000000000000)
            // Then it means this ticket is already sold
            marketItemsSold.add(marketItem);
          } else {
            marketItemsOnSale.add(marketItem);
          }
        }

        // Filter my tickets that i sell currently
        marketItemsOnSale.forEach((item) {
          if (item["seller"].toString().toLowerCase() ==
              widget.userProvider?.user?.publicAddress) {
            myItemsOnSale.add(item);
          }
        });

        // Filter my tickets that i own and don't sell
        marketItemsSold.forEach((item) {
          if (item["ticketOwner"].toString().toLowerCase() ==
              widget.userProvider?.user?.publicAddress) {
            myOwnItems.add(item);
          }
        });

        setState(() {
          _marketItemsAll = marketItemsAll;
          _marketItemsSold = marketItemsSold;
          _marketItemsOnSale = marketItemsOnSale;

          _myItemsOnSale = myItemsOnSale;
          _myOwnItems = myOwnItems;

          _isLoading = false;
        });
      });
    });
  }

  bool checkIfExpired() {
    List<String> eventStartDateSplit = widget.event.startDate!.split("-");
    List<String> eventStartTimeSplit = widget.event.startTime!.split(":");

    int startYear = int.parse(eventStartDateSplit[0]);
    int startMonth = int.parse(eventStartDateSplit[1]);
    int startDay = int.parse(eventStartDateSplit[2]);
    int startHour = int.parse(eventStartTimeSplit[0]);
    int startMinute = int.parse(eventStartTimeSplit[1]);

    DateTime eventStartDateTime =
        DateTime.utc(startYear, startMonth, startDay, startHour, startMinute);

    DateTime now = DateTime.now();

    return eventStartDateTime.compareTo(now) < 0;
  }

  // To mint tickets
  addMintedButton() {
    if (widget.event.owner == widget.userProvider?.user?.publicAddress &&
        _marketItemsAll.length == 0 &&
        _mintedTicketTokenIds.length == 0) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MintTicketPage(
                        event: widget.event,
                        userProvider: widget.userProvider!,
                        metamaskProvider: widget.metamaskProvider!,
                      ))).then((value) async {
            refreshTicketStatus();
          });
        },
        child: Icon(Icons.add_circle, size: 30, color: Color(0xFF050A31)),
      );
    } else {
      return SizedBox();
    }
  }

  // To sell minted tickets
  addListedButton() {
    if (widget.event.owner == widget.userProvider?.user?.publicAddress &&
        _mintedTicketTokenIds.length != 0 &&
        _mintedTicketTokenIds.length != _marketItemsAll.length) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SellTicketPage(
                        event: widget.event,
                        mintedTicketTokenIds: _mintedTicketTokenIds,
                        userProvider: widget.userProvider!,
                        metamaskProvider: widget.metamaskProvider!,
                      ))).then((value) async {
            refreshTicketStatus();
          });
        },
        child: Icon(Icons.add_circle, size: 30, color: Color(0xFF050A31)),
      );
    } else {
      return SizedBox();
    }
  }

  ticketStatusSection() {
    return Column(
      children: [
        Divider(thickness: 1),
        Container(
          height: 90,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Minted:
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Minted",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    _isLoading
                        ? Container(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.deepPurple,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            children: [
                              Text(
                                "${_mintedTicketTokenIds.length}",
                                style: TextStyle(fontSize: 24),
                              ),
                              addMintedButton(),
                            ],
                          ),
                  ],
                ),
              ),

              // Listed:
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Listed",
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    _isLoading
                        ? Container(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.deepPurple,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            children: [
                              Text(
                                "${_marketItemsAll.length}/${_mintedTicketTokenIds.length}",
                                style: TextStyle(fontSize: 24),
                              ),
                              addListedButton(),
                            ],
                          ),
                  ],
                ),
              ),

              // Sold
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sold",
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    _isLoading
                        ? Container(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.deepPurple,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "${_marketItemsSold.length}",
                            style: TextStyle(fontSize: 24),
                          ),
                  ],
                ),
              ),

              // On Sale
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "On Sale",
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    _isLoading
                        ? Container(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.deepPurple,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "${_marketItemsOnSale.length}",
                            style: TextStyle(fontSize: 24),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(thickness: 1),
      ],
    );
  }

  buyStopSaleButton(bool isSoldOut) {
    if (widget.event.owner == widget.userProvider?.user?.publicAddress) {
      // If i am the owner, show Stop Sale Button
      // Get all items that i sell
      return SizedBox();
    } else {
      // If i am a regular person, show Buy Button

      // If i am the one selling the cheapest item, then disable buy button
      bool isCheapestMine = _marketItemsOnSale.length > 0 &&
          widget.userProvider?.user?.publicAddress ==
              _marketItemsOnSale[0]["seller"].toString().toLowerCase();

      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: (isCheapestMine || isSoldOut)
                    ? Colors.grey
                    : Color(0xFFF99D23),
              ),
              onPressed: () async {
                if (widget.metamaskProvider!.isConnected) {
                  if (!isCheapestMine) {
                    // Buy a ticket

                    var transactionParameters = await marketService.buyTicket(
                        widget.userProvider!.token,
                        _marketItemsOnSale[0]["tokenID"],
                        _marketItemsOnSale[0]["price"]);
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
                        "value": transactionParameters["value"],
                        "data": transactionParameters["data"],
                      }
                    ];

                    String method = "eth_sendTransaction";

                    await launchUrl(
                        Uri.parse(
                            widget.metamaskProvider!.connector.session.toUri()),
                        mode: LaunchMode.externalApplication);

                    final signature = await widget.metamaskProvider!.connector
                        .sendCustomRequest(method: method, params: params);

                    refreshTicketStatus();
                  } else {
                    if (!isSoldOut) {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Sold Out!"),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: const <Widget>[
                                  Text(
                                      'There is no ticket left for this event.'),
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
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title:
                                const Text("You Cannot Buy Your Own Ticket!"),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: const <Widget>[
                                  Text(
                                      'The cheapest ticket is yours right now.'),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text("You can only buy other's tickets"),
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
                    }
                  }
                } else {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("You Need To Login First"),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: const <Widget>[
                              Text(
                                  'In order to buy a ticket, you need to login using your Metamask account.'),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                  "Please go to the Profile page to perform login."),
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
                }
              },
              child: Text(
                "Buy",
                style: TextStyle(fontSize: 22, color: Color(0xFF050A31)),
              ),
            ),
          ),
        ],
      );
    }
  }

  yourTicketStatusSection() {
    if (!widget.metamaskProvider!.isConnected) {
      // If metamask is not connected, then don't show this section
      return SizedBox();
    } else {
      return Container(
          padding: EdgeInsets.all(12),
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color(0xFFB9A6E0).withOpacity(0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Your Ticket Status",
                        style: TextStyle(
                            color: Color(0xFF050A31),
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(-2, 2),
                                blurRadius: 4,
                                spreadRadius: 2,
                                color: Color.fromRGBO(5, 10, 49, 0.1),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.refresh,
                            size: 30,
                          ),
                        ),
                        onTap: () {
                          refreshTicketStatus();
                        },
                      )
                    ],
                  ),
                  (_myOwnItems.length > 0 || _myItemsOnSale.length > 0)
                      ? GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(-2, 2),
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                  color: Color.fromRGBO(5, 10, 49, 0.1),
                                ),
                              ],
                            ),
                            child: Icon(
                              CupertinoIcons.arrow_right,
                              size: 30,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => YourTicketsPage(
                                          event: widget.event,
                                          userProvider: widget.userProvider,
                                          metamaskProvider:
                                              widget.metamaskProvider,
                                          myItemsOnSale: _myItemsOnSale,
                                          myOwnItems: _myOwnItems,
                                        ))).then((value) {});
                          },
                        )
                      : SizedBox()
                ],
              ),
              Divider(
                thickness: 1,
              ),
              Text(
                "You Own:",
                style: TextStyle(
                    color: Color(0xFF050A31),
                    fontSize: 18,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "General Admission",
                          style: TextStyle(
                              color: Color(0xFF050A31),
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                        ),
                        SizedBox(width: 30),
                        Text(
                          "x ${_myOwnItems.length}",
                          style: TextStyle(
                              color: Color(0xFF050A31),
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(thickness: 1),
              Text(
                "You Are Selling:",
                style: TextStyle(
                    color: Color(0xFF050A31),
                    fontSize: 18,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "General Admission",
                          style: TextStyle(
                              color: Color(0xFF050A31),
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                        ),
                        SizedBox(width: 30),
                        Text(
                          "x ${_myItemsOnSale.length}",
                          style: TextStyle(
                              color: Color(0xFF050A31),
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ),
                  _myItemsOnSale.length > 0
                      ? (widget.userProvider?.user?.publicAddress !=
                              widget.event.owner
                          ? GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Color(0xFF050A31)),
                                child: Center(
                                  child: Text(
                                    "Stop Sale",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              onTap: () async {
                                dynamic transactionParameters =
                                    await marketService.stopSale(
                                  widget.userProvider!.token,
                                  _myItemsOnSale[0]["tokenID"],
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
                                    "from": transactionParameters["from"],
                                    "to": transactionParameters["to"],
                                    "data": transactionParameters["data"],
                                  }
                                ];

                                String method = "eth_sendTransaction";

                                print(params);

                                await launchUrl(
                                    Uri.parse(widget
                                        .metamaskProvider!.connector.session
                                        .toUri()),
                                    mode: LaunchMode.externalApplication);

                                final signature = await widget
                                    .metamaskProvider!.connector
                                    .sendCustomRequest(
                                        method: method, params: params);

                                print("signature:" + signature);

                                refreshTicketStatus();
                              },
                            )
                          : SizedBox())
                      : SizedBox(),
                ],
              ),
            ],
          ));
    }
  }

  buySection() {
    bool isExpired = checkIfExpired();

    if (isExpired) {
      return expiredContainer();
    } else {
      if (_marketItemsAll.length > 0) {
        bool isSoldOut = _marketItemsOnSale.length == 0;

        return Container(
            padding: EdgeInsets.all(12),
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color(0xFFE9F2F6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.tickets_fill,
                          color: Color(0xFF050A31),
                          size: 30,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "General Admission",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    _isLoading
                        ? Container(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.deepPurple,
                              strokeWidth: 2,
                            ),
                          )
                        : (isSoldOut
                            ? Text(
                                "Sold Out",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Starting at",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Text(
                                      "MATIC ${_marketItemsOnSale[0]['price']}",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  )
                                ],
                              ))
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas bibendum ex at velit luctus rutrum. Pellentesque nec condimentum libero. Phasellus nulla justo, pretium a ullamcorper at, vestibulum ut sem. Curabitur scelerisque tincidunt lacus, a imperdiet enim pulvinar in.",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                buyStopSaleButton(isSoldOut),
              ],
            ));
      } else {
        return Text("There is no issued tickets right now...");
      }
    }
  }

  expiredContainer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 50,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          "This event is expired!",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Future<bool> getIsTicketController(publicAddress, eventID) async {
    bool res = await eventService.isTicketController(publicAddress, eventID);
    return res;
  }

  // _marketItemsAll.length > 0
  floatingActionButton() {
    if (_marketItemsAll.length > 0) {
      return FutureBuilder(
          future: getIsTicketController(
              widget.userProvider?.user?.publicAddress, widget.event.integerId),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!) {
              return FloatingActionButton(
                heroTag: "qrButton",
                elevation: 0.0,
                child: new Icon(
                  CupertinoIcons.qrcode_viewfinder,
                  color: Colors.white,
                  size: 40,
                ),
                backgroundColor: Color(0xFF050A31),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ScanPage(
                                event: widget.event,
                                userProvider: widget.userProvider!,
                                metamaskProvider: widget.metamaskProvider!,
                                marketItemsAll: _marketItemsAll,
                              ))).then((value) async {
                    refreshTicketStatus();
                  });
                },
              );
            }
            return Container();
          });
    }
    return Container();
  }

  setTicketController() {
    if (widget.event.owner == widget.userProvider?.user?.publicAddress &&
        _marketItemsAll.length > 0) {
      return FloatingActionButton(
        heroTag: "ticketControllerButton",
        elevation: 0.0,
        child: new Icon(
          CupertinoIcons.person_2_square_stack,
          color: Colors.white,
          size: 40,
        ),
        backgroundColor: Color(0xFF050A31),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SetTicketControllerPage(
                        event: widget.event,
                        userProvider: widget.userProvider!,
                        metamaskProvider: widget.metamaskProvider!,
                      ))).then((value) async {
            refreshTicketStatus();
          });
        },
      );
    } else {
      return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.parse(widget.event.startDate!);
    String day = DateFormat('EEEE').format(date).substring(0, 3);
    String formattedStart = day + DateFormat(', MMMM d').format(date);
    date = DateTime.parse(widget.event.endDate);
    day = DateFormat('EEEE').format(date).substring(0, 3);
    String formattedEnd = day + DateFormat(', MMMM d').format(date);

    getOwner();
    return Scaffold(
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            setTicketController(),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: floatingActionButton(),
            )
          ]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcATop,
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color.fromRGBO(5, 10, 50, 0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  child: Image.network(
                    widget.event!.coverImageURL ?? "",
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        backButtonWhite(context),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    bottom: 30,
                    left: 20,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      child: Text(
                        widget.event.title,
                        style: const TextStyle(
                            overflow: TextOverflow.fade,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 28),
                      ),
                    ))
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 1,
              decoration: const BoxDecoration(
                color: Color(0xFF050A31),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(-5, -20),
                    blurRadius: 40,
                    spreadRadius: 20,
                    color: Color.fromRGBO(5, 10, 49, 0.8),
                  ),
                ],
              ),
            ),
            (widget.event.owner == widget.userProvider?.user?.publicAddress
                ? Container(
                    padding: EdgeInsets.only(top: 15),
                    child: Text(
                      "You are organising this event! ",
                      style: TextStyle(
                          color: Colors.red[800], fontWeight: FontWeight.w700),
                    ),
                  )
                : SizedBox()),
            FutureBuilder<User>(
                future: owner,
                builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius:
                                MediaQuery.of(context).size.width * 30 / 375,
                            backgroundImage: NetworkImage(snapshot
                                    .data!.avatar ??
                                "https://static.vecteezy.com/system/resources/previews/007/126/739/original/question-mark-icon-free-vector.jpg"),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                10,
                                MediaQuery.of(context).size.width * 10 / 375,
                                0,
                                0),
                            child: Column(
                              children: [
                                Text("Organiser"),
                                Text(
                                  snapshot.data!.username,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }
                  return SizedBox();
                }),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    widget.event.startDate != widget.event.endDate
                        ? formattedStart + " - " + formattedEnd
                        : formattedStart,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    widget.event.startTime + " - " + widget.event.endTime,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(15, 30, 15, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(widget.event.description),
                ],
              ),
            ),
            SizedBox(height: 20),
            checkIfExpired() ? expiredContainer() : SizedBox(),
            SizedBox(height: 20),
            ticketStatusSection(),
            SizedBox(height: 30),
            yourTicketStatusSection(),
            SizedBox(height: 30),
            buySection(),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
