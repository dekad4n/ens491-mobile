import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';

class ViewAuctionsPage extends StatefulWidget {
  final Event? event;
  final UserProvider? userProvider;
  final MetamaskProvider? metamaskProvider;

  const ViewAuctionsPage({
    super.key,
    this.event,
    this.userProvider,
    this.metamaskProvider,
  });

  @override
  State<ViewAuctionsPage> createState() => _ViewAuctionsPageState();
}

class _ViewAuctionsPageState extends State<ViewAuctionsPage> {
  List<dynamic> auctions = [];
  bool _isLoading = true;

  void refreshTicketStatus() {
    setState(() {
      _isLoading = true;
    });

    //TODO: refresh data
  }

  ticketsGridView() {
    if (_isLoading) {
      return Center(child: Text("Loading auctions..."));
    } else {
      return Container(padding: EdgeInsets.all(12), color: Colors.red);
      //   return Container(
      //   width: double.infinity,
      //   height: ((list.length / 3).ceil() + 1) * 70,
      //   constraints: BoxConstraints(maxHeight: 4 * 70),
      //   child: GridView.count(
      //       primary: false,
      //       padding: const EdgeInsets.all(8),
      //       childAspectRatio: (4 / 5),
      //       crossAxisSpacing: 10,
      //       mainAxisSpacing: 10,
      //       crossAxisCount: 3,
      //       children: tickets),
      // );
    }
  }

  auctionTicketsSection() {
    return Container(
      padding: EdgeInsets.all(12),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade500, width: 1),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tickets On Auction:",
                style: TextStyle(
                    color: Color(0xFF050A31),
                    fontSize: 18,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
          Divider(thickness: 1),
          SizedBox(height: 10),
          ticketsGridView(),
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
          "View Auctions",
          style: TextStyle(
            color: Color(0xff050a31),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            auctionTicketsSection(),
          ],
        ),
      ),
    );
  }
}
