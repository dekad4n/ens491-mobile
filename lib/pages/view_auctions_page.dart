import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/pages/auction_page.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:tickrypt/services/auction.dart';

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
  AuctionService auctionService = AuctionService();

  List<dynamic> auctions = [];
  bool _isLoading = true;

  void fetchOngoingAuctions() async {
    setState(() {
      _isLoading = true;
    });

    // Fetch auctions
    List<dynamic> fetchedAuctions =
        await auctionService.getAuctionsByEventId(widget.event!.integerId);

    print(fetchedAuctions);

    setState(() {
      auctions = fetchedAuctions;
      _isLoading = false;
    });
  }

  auctionsGridView(color) {
    if (_isLoading) {
      return Center(child: Text("Loading auctions..."));
    } else {
      List<Widget> auctionWidgets = auctions.map((item) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // Navigator.push(context, MaterialPageRoute(
            //   builder: (context) {
            //     return AuctionPage(
            //         userProvider: widget.userProvider,
            //         metamaskProvider: widget.metamaskProvider,
            //         event: widget.event,
            //         item: ticket item here!!!);
            //   },
            // ));
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: color.withOpacity(0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Text("Auction", style: TextStyle(color: Colors.white)),
                      Text(
                        "${item["auctionId"]}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                                CupertinoIcons.ticket_fill,
                                color: Colors.white,
                              ),
                              // Text(
                              //   "seat:",
                              //   style: TextStyle(color: Colors.white),
                              // ),
                              Text(
                                "id: ${item["ticketId"]}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                "${item["highestBid"]}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                item["seller"].toLowerCase() ==
                        widget.userProvider!.user!.publicAddress.toLowerCase()
                    ? Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                          color: Colors.green,
                        ),
                        child: Center(
                          child: Text("Your auction",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      )
                    : SizedBox()
              ],
            ),
          ),
        );
      }).toList();

      return Container(
        width: double.infinity,
        height: ((auctions.length / 3).ceil() + 1) * 70,
        constraints: BoxConstraints(maxHeight: 4 * 70),
        child: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(8),
            childAspectRatio: (4 / 5),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 3,
            children: auctionWidgets),
      );
    }
  }

  ticketsOnAuction() {
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
                "Tickets on auction:",
                style: TextStyle(
                    color: Color(0xFF050A31),
                    fontSize: 18,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
          Divider(thickness: 1),
          SizedBox(height: 10),
          auctionsGridView(Colors.grey[700]),
        ],
      ),
    );
  }

  initState() {
    super.initState();

    fetchOngoingAuctions();
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
            ticketsOnAuction(),
          ],
        ),
      ),
    );
  }
}
