import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/pages/resell_ticket_page.dart';
import 'package:tickrypt/pages/transfer_page.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:tickrypt/services/market.dart';

class TicketPage extends StatefulWidget {
  final Event? event;
  final UserProvider? userProvider;
  final MetamaskProvider? metamaskProvider;
  final List<dynamic>? myOwnItems;
  final List<dynamic>? myItemsOnSale;

  const TicketPage(
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

  showDialogOnPressOwn(item) {
    bool isTransferable = item["transferRight"] > 0;

    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Ticket"),
              Text("id: ${item["tokenID"]}",
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    "This ticket is transferable ${item["transferRight"]} times."),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (isTransferable) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TransferPage(
                                    event: widget.event,
                                    userProvider: widget.userProvider!,
                                    metamaskProvider: widget.metamaskProvider!,
                                    item: item,
                                  ))).then((value) {});
                    }
                  },
                  child: Text("Transfer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isTransferable ? Color(0xFFF99D23) : Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (isTransferable) {
                      print("resell single item");
                    }
                  },
                  child: Text("Resell"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isTransferable ? Color(0xFFF99D23) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF5200FF)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  ticketsGridView(List<dynamic> list, Color color, String sellOrOwn) {
    List<Widget> tickets = list
        .map((item) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (sellOrOwn == "sell") {}
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
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                        color: color,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Ticket",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "seat:",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "${item["seat"]}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "transfer:",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "${item["transferRight"]}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
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
      height: (list.length / 3 + 1) * 40,
      child: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(8),
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
                      "You Own:",
                      style: TextStyle(
                          color: Color(0xFF050A31),
                          fontSize: 18,
                          fontWeight: FontWeight.w400),
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
                        // refreshTicketStatus();
                      },
                    )
                  ],
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
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
                    child: Text(
                      "Resell Multiple",
                      style: TextStyle(fontSize: 16),
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
                                )));
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
                Text(
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
    for (var x in widget.myOwnItems!) print(x);
    if (widget.myItemsOnSale!.length > 0) {
      return Container(
        padding: EdgeInsets.all(12),
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color.fromARGB(255, 224, 166, 166).withOpacity(0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You Are Selling:",
              style: TextStyle(
                  color: Color(0xFF050A31),
                  fontSize: 18,
                  fontWeight: FontWeight.w400),
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
                Text(
                  "x ${widget.myItemsOnSale?.length}",
                  style: TextStyle(
                      color: Color(0xFF050A31),
                      fontSize: 16,
                      fontWeight: FontWeight.w300),
                ),
              ],
            ),
            SizedBox(height: 10),
            ticketsGridView(widget.myItemsOnSale!, Colors.deepOrange, "sell"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_drop_down,
                  size: 30,
                  color: Colors.grey,
                )
              ],
            ),
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
                  youOwnSection(),
                  SizedBox(height: 10),
                  youAreSellingSection(),
                ],
              )),
        ),
      ),
    );
  }
}
