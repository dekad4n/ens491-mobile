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

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  UserService userService = UserService();
  late Future<List<Event>> events;

  void getEvents(publicAddress) {
    setState(() {
      events = userService.getEvents(publicAddress);
    });
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

  attendingEventsSection(UserProvider userProvider) {
    if (userProvider.isWhitelisted != null &&
        userProvider.isWhitelisted == true) {
      return Text("");
    } else {
      ///TODO: Add attending events section
      return Text("Attending");
    }
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
