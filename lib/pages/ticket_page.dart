import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/pages/resell_ticket_page.dart';
import 'package:tickrypt/pages/transfer_page.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:tickrypt/services/market.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketPage extends StatefulWidget {
  Event? event;
  UserProvider? userProvider;
  MetamaskProvider? metamaskProvider;
  List<dynamic>? myOwnItems;
  List<dynamic>? myItemsOnSale;

  TicketPage(
      {super.key,
      this.event,
      this.userProvider,
      this.metamaskProvider,
      this.myOwnItems,
      this.myItemsOnSale});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  MarketService marketService = MarketService();

  String _targetPublicAdddress = "";
  double _price = 0;
  double comission = 0;

  bool _isLoading = false;

  final alchemy = Alchemy();

  int mySortComparison(dynamic item1, dynamic item2) {
    if (item1["price"] < item2["price"]) {
      return -1;
    } else if (item1["price"] > item2["price"]) {
      return 1;
    } else {
      return 0;
    }
  }

  Future<List<dynamic>> getMarketItemsAll() async {
    List<dynamic> marketItemsAll =
        await marketService.getMarketItemsAllByEventId(widget.event!.integerId);

    marketItemsAll.sort(mySortComparison);

    return marketItemsAll;
  }

  void refreshTicketStatus() {
    setState(() {
      _isLoading = true;
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
        widget.myItemsOnSale = myItemsOnSale;
        widget.myOwnItems = myOwnItems;

        _isLoading = false;
      });
    });
  }

  refreshButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
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
              children: [
                Text("Refresh", style: TextStyle(color: Colors.white)),
                Icon(
                  Icons.refresh,
                  size: 30,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        refreshTicketStatus();
      },
    );
  }

  targetPublicAddressTextField() {
    return TextFormField(
      style: TextStyle(fontSize: 15),
      // The validator receives the text that the user has entered.
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.deepPurple)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          labelText: 'Public Address',
          labelStyle: TextStyle(color: Colors.grey)),
      cursorColor: Colors.deepPurple,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        } else {
          setState(() {
            _targetPublicAdddress = value;
          });
        }
        return null;
      },
      onChanged: (value) {
        if (value != null || value != "") {
          setState(() {
            _targetPublicAdddress = value;
          });
        }
      },
    );
  }

  priceContainer() {
    return TextFormField(
      style: TextStyle(
        fontSize: 15,
      ),
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.deepPurple)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          labelText: 'Price (MATIC)',
          labelStyle: TextStyle(color: Colors.grey)),
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
    );
  }

  showDialogOnPressOwn(item) {
    bool isTransferable = item["transferRight"] > 0;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Ticket"),
                  Text("id: ${item["tokenID"]}",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "This ticket is transferable ${item["transferRight"]} times.",
                  style: TextStyle(color: Colors.red[900]),
                ),
                Divider(thickness: 1),
                SizedBox(height: 10),
                Text("Send this ticket to someone"),
                SizedBox(height: 10),
                targetPublicAddressTextField(),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (isTransferable) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      );

                      dynamic transactionParameters =
                          await marketService.transfer(
                        widget.userProvider!.token,
                        item["tokenID"],
                        _targetPublicAdddress,
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

                      Navigator.of(context).pop();
                      refreshTicketStatus();
                    }
                  },
                  child: Text("Transfer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isTransferable ? Color(0xFF050A31) : Colors.grey,
                  ),
                ),
                Divider(thickness: 1),
                SizedBox(height: 10),
                Text("Resell in the market"),
                SizedBox(height: 10),
                priceContainer(),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (isTransferable && _price > 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      );

                      dynamic transactionParameters =
                          await marketService.resell(
                        widget.userProvider!.token,
                        _price,
                        [item["tokenID"]],
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

                      Navigator.of(context).pop();
                      refreshTicketStatus();
                    }
                  },
                  child: Text("Resell"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isTransferable ? Color(0xFF050A31) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showDialogOnPressSell(item) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Ticket"),
                  Text("id: ${item["tokenID"]}",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "This ticket is transferable ${item["transferRight"]} times.",
                  style: TextStyle(color: Colors.red[900]),
                ),
                Divider(thickness: 1),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );

                    dynamic transactionParameters =
                        await marketService.stopSale(
                      widget.userProvider!.token,
                      item["tokenID"],
                    );

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
                        .sendCustomRequest(method: method, params: params);

                    print("signature:" + signature);

                    Navigator.of(context).pop();

                    refreshTicketStatus();
                  },
                  child: Text("Stop Sale"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF050A31),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ticketsGridView(List<dynamic> list, Color color, String sellOrOwn) {
    if (_isLoading) {
      return Text("Loading tickets...");
    }

    List<Widget> tickets = list
        .map((item) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (sellOrOwn == "sell") {
                  showDialogOnPressSell(item);
                }
                if (sellOrOwn == "own") {
                  showDialogOnPressOwn(item);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: color.withOpacity(0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                        color: color,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Ticket", style: TextStyle(color: Colors.white)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "id:",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "${item["tokenID"]}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.event_seat,
                                color: Colors.white,
                              ),
                              // Text(
                              //   "seat:",
                              //   style: TextStyle(color: Colors.white),
                              // ),
                              Text(
                                "${item["seat"]}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Text(
                              //   "transfer:",
                              //   style: TextStyle(color: Colors.white),
                              // ),
                              Icon(
                                CupertinoIcons
                                    .arrow_right_arrow_left_square_fill,
                                color: Colors.white,
                              ),
                              Text(
                                "${item["transferRight"]}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          sellOrOwn == "sell"
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Text(
                                    //   "price:",
                                    //   style: TextStyle(color: Colors.white),
                                    // ),
                                    Icon(
                                      Icons.payments_sharp,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      "${item["price"]}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();

    return Container(
      width: double.infinity,
      height: ((list.length / 3).ceil() + 1) * 70,
      constraints: BoxConstraints(maxHeight: 4 * 70),
      child: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(8),
          childAspectRatio: (4 / 5),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 3,
          children: tickets),
    );
  }

  youOwnSection() {
    if (widget.myOwnItems!.length > 0) {
      return Container(
        padding: EdgeInsets.all(12),
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
          color: Color(0xFFB9A6E0).withOpacity(0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "You Own:",
                  style: TextStyle(
                      color: Color(0xFF050A31),
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
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
                    child: Text(
                      "Resell Multiple",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ResellTicketPage(
                                  event: widget.event!,
                                  userProvider: widget.userProvider!,
                                  metamaskProvider: widget.metamaskProvider!,
                                  myOwnItems: widget.myOwnItems!,
                                ))).then((value) {
                      refreshTicketStatus();
                    });
                  },
                )
              ],
            ),
            Divider(thickness: 1),
            Row(
              children: [
                Text(
                  "General Admission",
                  style: TextStyle(
                      color: Color(0xFF050A31),
                      fontSize: 16,
                      fontWeight: FontWeight.w300),
                ),
                SizedBox(width: 20),
                _isLoading
                    ? Container(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "x ${widget.myOwnItems?.length}",
                        style: TextStyle(
                            color: Color(0xFF050A31),
                            fontSize: 16,
                            fontWeight: FontWeight.w300),
                      ),
              ],
            ),
            SizedBox(height: 10),
            ticketsGridView(widget.myOwnItems!, Colors.deepPurple, "own"),
          ],
        ),
      );
    } else {
      return SizedBox();
    }
  }

  youAreSellingSection() {
    if (widget.myItemsOnSale!.length > 0) {
      return Container(
        padding: EdgeInsets.all(12),
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
          color: Color(0xFFE9F2F6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "You Are Selling:",
                  style: TextStyle(
                      color: Color(0xFF050A31),
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
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
                    child: Text(
                      "Stop Batch Sale",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  onTap: () async {
                    /// TODO : Stop batch Sale
                    if (widget.myItemsOnSale!.length > 0) {
                      List<dynamic> tokenIds = widget.myItemsOnSale!
                          .map((e) => e["tokenID"])
                          .toList();

                      dynamic transactionParameters =
                          await marketService.stopBatchSale(
                        widget.userProvider!.token,
                        tokenIds,
                        widget.event!.integerId,
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
                          Uri.parse(widget.metamaskProvider!.connector.session
                              .toUri()),
                          mode: LaunchMode.externalApplication);

                      final signature = await widget.metamaskProvider!.connector
                          .sendCustomRequest(method: method, params: params);

                      print("signature:" + signature);

                      refreshTicketStatus();
                    }
                  },
                )
              ],
            ),
            Divider(thickness: 1),
            Row(
              children: [
                Text(
                  "General Admission",
                  style: TextStyle(
                      color: Color(0xFF050A31),
                      fontSize: 16,
                      fontWeight: FontWeight.w300),
                ),
                SizedBox(width: 20),
                _isLoading
                    ? Container(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "x ${widget.myItemsOnSale?.length}",
                        style: TextStyle(
                            color: Color(0xFF050A31),
                            fontSize: 16,
                            fontWeight: FontWeight.w300),
                      ),
              ],
            ),
            SizedBox(height: 10),
            ticketsGridView(
                widget.myItemsOnSale!, Colors.blue.shade700, "sell"),
          ],
        ),
      );
    } else {
      return SizedBox();
    }
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
          "Your Tickets",
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
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  refreshButton(),
                  SizedBox(height: 20),
                  youOwnSection(),
                  SizedBox(height: 20),
                  youAreSellingSection(),
                ],
              )),
        ),
      ),
    );
  }
}
