import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';

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
  ticketRectangle() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
    );
  }

  ticketsGridView(List<dynamic> list, Color color) {
    List<Widget> tickets = list
        .map((item) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: color,
              ),
              child: Center(
                child: Text(
                  item["tokenID"].toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ))
        .toList();

    return Container(
      width: double.infinity,
      height: (list.length / 10 + 1) * 30,
      child: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(8),
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          crossAxisCount: 10,
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
            Text(
              "You Own:",
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
                  "x ${widget.myOwnItems?.length}",
                  style: TextStyle(
                      color: Color(0xFF050A31),
                      fontSize: 16,
                      fontWeight: FontWeight.w300),
                ),
              ],
            ),
            SizedBox(height: 10),
            ticketsGridView(widget.myOwnItems!, Colors.purple),
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
            ticketsGridView(widget.myItemsOnSale!, Colors.deepOrange),
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
