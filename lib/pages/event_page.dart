import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tickrypt/models/user_model.dart';
import 'package:tickrypt/pages/sell_ticket_page.dart';
import 'package:tickrypt/pages/mint_ticket_page.dart';
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
  final alchemy = Alchemy();

  UserService userService = UserService();
  EventService eventService = EventService();
  MarketService marketService = MarketService();

  late Future<User> owner;

  List<dynamic> _mintedTicketTokenIds = [];
  List<dynamic> _marketItemsAll = [];
  List<dynamic> _marketItemsSold = [];
  List<dynamic> _marketItemsOnSale = [];

  void getOwner() {
    setState(() {
      owner = userService.getNonce(widget.event.owner);
    });
  }

  Future<List<dynamic>> getMintedEventTicketTokens() async {
    List<dynamic> mintedEventTicketTokens =
        await eventService.getMintedEventTicketIds(widget.event.integerId);

    // An example return: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    // for (dynamic tokenId in mintedEventTicketTokens) {
    //   print(tokenId);
    //   final String url =
    //       'http://10.51.20.179:3001/market/market-item?tokenId=$tokenId';

    //   await get(Uri.parse(url));

    //   // var body = jsonDecode(res.body);

    //   // print(body);
    // }
    setState(() {
      _mintedTicketTokenIds = mintedEventTicketTokens;
    });
    return mintedEventTicketTokens;
  }

  Future<List<dynamic>> getMarketItemsAll() async {
    List<dynamic> marketItemsAll =
        await marketService.getMarketItemsAllByEventId(widget.event.integerId);

    print(marketItemsAll);
    return marketItemsAll;
  }

  // Future<List<dynamic>> getMarketItems() async {
  //   List<dynamic> marketItems = await ;
  //   return marketItems;
  // }

  ticketStatusContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(12),
      width: MediaQuery.of(context).size.width * 0.60,
      child: Column(
        children: [
          Text(
            "Ticket Status",
            style: TextStyle(fontSize: 16),
          ),

          SizedBox(height: 10),

          // Minted:
          Container(
            padding: EdgeInsets.all(2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.tickets_fill,
                      size: 30,
                      color: Colors.deepPurple[800],
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Minted:",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(width: 10),
                    FutureBuilder(
                        future: getMintedEventTicketTokens(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<dynamic>> snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.deepPurple,
                            );
                          } else {
                            return Text(
                              "${snapshot.data!.length}",
                              style: TextStyle(fontSize: 24),
                            );
                          }
                        }),
                  ],
                ),
                (widget.event.owner ==
                            widget.userProvider?.user?.publicAddress &&
                        _marketItemsAll.length == 0)
                    ? addMintedButton()
                    : Text(""),
              ],
            ),
          ),

          SizedBox(height: 10),

          // Listed:
          Container(
            padding: EdgeInsets.all(2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.tickets_fill,
                      size: 30,
                      color: Colors.deepPurple[800],
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Listed:",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "${_marketItemsAll.length}",
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                (widget.event.owner ==
                            widget.userProvider?.user?.publicAddress &&
                        _mintedTicketTokenIds.length != 0)
                    ? addListedButton()
                    : Text(""),
              ],
            ),
          ),

          SizedBox(height: 10),

          // Sold
          Container(
            padding: EdgeInsets.all(2),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.tickets_fill,
                  size: 30,
                  color: Colors.deepPurple[800],
                ),
                SizedBox(width: 10),
                Text(
                  "Sold:",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                ),
                SizedBox(width: 10),
                Text(
                  "${_marketItemsSold.length}",
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          // On Sale
          Container(
            padding: EdgeInsets.all(2),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.tickets_fill,
                  size: 30,
                  color: Colors.deepPurple[800],
                ),
                SizedBox(width: 10),
                Text(
                  "On Sale:",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                ),
                SizedBox(width: 10),
                Text(
                  "${_marketItemsOnSale.length}",
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // To mint tickets
  addMintedButton() {
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
                    ))).then((value) => setState(() {}));
      },
      child: Icon(Icons.add_circle, size: 30, color: Color(0xFF050A31)),
    );
  }

  // To sell minted tickets
  addListedButton() {
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
                    ))).then((value) => setState(() {}));
      },
      child: Icon(Icons.add_circle, size: 30, color: Color(0xFF050A31)),
    );
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
                            child: Text(
                              snapshot.data!.username,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                  return Text("");
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
            SizedBox(height: 30),
            ticketStatusContainer(),
          ],
        ),
      ),
    );
  }
}
