import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:tickrypt/services/user.dart';
import 'package:tickrypt/widgets/atoms/buttons/primaryElevatedButton.dart';
import 'package:tickrypt/widgets/organisms/events/profileEvents.dart';
import 'package:tickrypt/widgets/organisms/headers/profileHeader.dart';

import '../models/user_model.dart';
import 'event_page.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  UserService userService = UserService();
  late Future<List<Event>> events;
  late Future<Map<dynamic, dynamic>> tickets;
  List<dynamic> searchResultEventList = [];
  void getEvents(publicAddress) {
    setState(() {
      events = userService.getEvents(publicAddress);
    });
  }

  void getTickets(publicAddress) {
    setState(() {
      tickets = userService.getTickets(publicAddress);
    });
  }

  Future<User> getOwner(publicAddress) async {
    var res = await userService.getNonce(publicAddress);
    return res;
  }

  myEventsSection(UserProvider userProvider) {
    if (userProvider.isWhitelisted == null ||
        userProvider.isWhitelisted == false) {
      return Text("");
    }
    if (userProvider.isWhitelisted!) {
      return FutureBuilder<List<Event>>(
          future: events,
          builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
            if (snapshot.hasData) {
              return profileEvents(
                  context, snapshot.data!, userProvider, setState);
            }
            return Text("");
          });
    }
  }

  Card horizontalEventCard(Event e, userProvider, User owner) {
    //Get owner username and avatar
    String? ownerUsername = owner.username;
    String? ownerAvatar = owner.avatar;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
      elevation: 10,
      shadowColor: Colors.black,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 9 / 10,
        height: 200,

        child: GestureDetector(
          onTap: () {
            //Go to the event's page

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventPage(
                          event: e,
                          userProvider: userProvider,
                        )));
          },
          behavior: HitTestBehavior.opaque,
          child: ClipPath(
            clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            child: Row(
              children: [
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 20,
                                backgroundImage: NetworkImage(ownerAvatar ??
                                    "https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Question_mark_%28black%29.svg/1024px-Question_mark_%28black%29.svg.png"),
                              ),
                              SizedBox(width: 15),
                              Flexible(
                                child: Text(
                                  ownerUsername,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 5),
                          Expanded(
                            child: Container(
                              child: Text(
                                e.title!,
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w900),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Starting at",
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "FREE",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(e.coverImageURL!),
                            fit: BoxFit.cover,
                            alignment: Alignment.bottomCenter),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  e.startDate!,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  e.startTime!,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
        //Padding
      ), //SizedBox
    );
  }

  getPastValues(var val, UserProvider userProvider) {
    if (DateTime.parse(val["event"]["startDate"]).isBefore(DateTime.now())) {
      return FutureBuilder(
          future: getOwner(val["event"]["owner"]),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occurred',
                    style: TextStyle(fontSize: 18),
                  ),
                );

                // if we got our data
              } else if (snapshot.hasData) {
                // Extracting data from snapshot object
                return horizontalEventCard(
                    Event.fromJson(val["event"]), userProvider, snapshot.data!);
              }
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          });
    }
    return Container();
  }

  getCurrentValues(var val, UserProvider userProvider) {
    if (!DateTime.parse(val["event"]["startDate"]).isBefore(DateTime.now())) {
      return FutureBuilder(
          future: getOwner(val["event"]["owner"]),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occurred',
                    style: TextStyle(fontSize: 18),
                  ),
                );

                // if we got our data
              } else if (snapshot.hasData) {
                // Extracting data from snapshot object
                return horizontalEventCard(
                    Event.fromJson(val["event"]), userProvider, snapshot.data!);
              }
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          });
    }
    return Container();
  }

  attendingEventsSection(UserProvider userProvider) {
    return FutureBuilder(
        future: tickets,
        builder: (BuildContext context,
            AsyncSnapshot<Map<dynamic, dynamic>> snapshot) {
          if (snapshot.hasData) {
            return Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Attending",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var val in snapshot.data!.values)
                            getCurrentValues(val, userProvider),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Row(
                              children: [
                                Text(
                                  "Past",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                    color: Color(0xFF050A31).withOpacity(0.5),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        7 /
                                        10,
                                    height: 1,
                                    color: Color.fromRGBO(5, 10, 49, 0.3),
                                  ),
                                )
                              ],
                            ),
                          ),
                          for (var val in snapshot.data!.values)
                            getPastValues(val, userProvider)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }
          return Text("yok");
        });
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    print(userProvider.token);
    var metamaskProvider = Provider.of<MetamaskProvider>(context);
    if (!metamaskProvider.isConnected) {
      return (Scaffold(
        body: Container(
          alignment: Alignment.topLeft,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              stops: [0.7272, 0.9733],
              colors: [
                Color(0xFF050A31),
                Color(0xFF6D6C9F),
              ],
              transform: GradientRotation(347.69 * (3.14 / 180)),
            ),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Image.asset(
              'lib/assets/login_top_part.png',
              color: Color(0xFF050a31),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0, 0, 20),
              child: Text(
                "Go Outside.",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.normal),
              ),
            ),
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 300 / 354,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xFF5200FF),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      metamaskProvider.loginUsingMetamask();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const <Widget>[
                              FittedBox(
                                child: Text(
                                  "Log-in with",
                                  softWrap: false,
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 42,
                                      fontFamily: 'Avenir',
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              Text(
                                " Metamask",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontFamily: 'Avenir',
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(
                            CupertinoIcons.arrow_right,
                            color: Colors.white,
                            size: 40,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          ]), // your child widget here
        ),
      ));
    }
    if (userProvider.token == "") {
      userProvider.handleLogin(metamaskProvider);
      return Scaffold();
    }
    getEvents(metamaskProvider.currentAddress);
    getTickets(metamaskProvider.currentAddress);
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              profileHeader(context, userProvider.user, setState),
              myEventsSection(userProvider),
              attendingEventsSection(userProvider),
            ],
            // Get Minted Tickets
          ),
        ),
      ),
    );
  }
}
