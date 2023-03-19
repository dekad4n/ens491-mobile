import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:tickrypt/services/user.dart';
import 'package:tickrypt/services/utils.dart';
import 'package:tickrypt/widgets/atoms/buttons/backButton.dart';

import '../models/category_model.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../providers/metamask.dart';
import '../providers/user_provider.dart';
import 'event_page.dart';

class CategoryPage extends StatefulWidget {
  final dynamic category;
  final UserProvider? userProvider;
  final MetamaskProvider? metamaskProvider;

  const CategoryPage(
      {super.key, this.category, this.userProvider, this.metamaskProvider});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

UtilsService utilsService = UtilsService();
UserService userService = UserService();
Future<Card> horizontalEventCard(
    Event e, userProvider, metamaskProvider, context) async {
  //Get owner username and avatar
  User owner = await userService.getNonce(e.owner);
  String? ownerUsername = owner.username;
  String? ownerAvatar = owner.avatar;

  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    margin: EdgeInsets.symmetric(vertical: 15),
    elevation: 10,
    shadowColor: Colors.black,
    child: SizedBox(
      width: double.infinity,
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
                        metamaskProvider: metamaskProvider,
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
                                  "Event id: ${e.integerId}",
                                  style: TextStyle(
                                    color: Colors.grey,
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
                  child: Stack(
                    children: [
                      Positioned(
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
                      Positioned(
                        child: cardExpiredBadge(e),
                      ),
                      Positioned(
                        right: 0,
                        child: cardYouOrganiseBadge(e, userProvider),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
      //Padding
    ), //SizedBox
  );
}

cardExpiredBadge(Event event) {
  List<String> eventStartDateSplit = event.startDate!.split("-");
  List<String> eventStartTimeSplit = event.startTime!.split(":");

  int startYear = int.parse(eventStartDateSplit[0]);
  int startMonth = int.parse(eventStartDateSplit[1]);
  int startDay = int.parse(eventStartDateSplit[2]);
  int startHour = int.parse(eventStartTimeSplit[0]);
  int startMinute = int.parse(eventStartTimeSplit[1]);

  DateTime eventStartDateTime =
      DateTime.utc(startYear, startMonth, startDay, startHour, startMinute);

  DateTime now = DateTime.now();

  if (eventStartDateTime.compareTo(now) < 0) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(8),
          )),
      child: Text(
        "Expired",
        style: TextStyle(color: Colors.white),
      ),
    );
  } else {
    return SizedBox();
  }
}

cardYouOrganiseBadge(Event event, UserProvider userProvider) {
  if (event.owner == userProvider.user?.publicAddress) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8),
          )),
      child: Text(
        "Organising",
        style: TextStyle(color: Colors.white),
      ),
    );
  } else {
    return SizedBox();
  }
}

Future<List<Card>> getEvents(
    userProvider, metamaskProvider, widget, context) async {
  String searchTitle = "";
  String id = "";
  int page = 1;
  int pageLimit = 10;

  List<Event> events =
      await utilsService.getEventsByCategory(widget.category.name);

  List<Card> eventCards = [];

  for (Event e in events) {
    Card eventCard =
        await horizontalEventCard(e, userProvider, metamaskProvider, context);
    eventCards.add(eventCard);
  }
  return eventCards;
}

eventsSection(userProvider, metamaskProvider, widget, context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        FutureBuilder(
          future: getEvents(userProvider, metamaskProvider, widget, context),
          builder: (ctx, snapshot) {
            // Checking if future is resolved or not
            if (snapshot.connectionState == ConnectionState.done) {
              // If we got an error
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
                return Column(
                  children: snapshot.data!,
                );
              }
            }

            // Displaying LoadingSpinner to indicate waiting state
            return Center(
              child: CircularProgressIndicator(),
            );
          },

          // Future that needs to be resolved
          // inorder to display something on the Canvas
        ),
      ],
    ),
  );
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(widget.category.image,
                    width: MediaQuery.of(context).size.width, fit: BoxFit.fill),
                Positioned(
                  child: Text(
                    widget.category.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  bottom: 15,
                  right: 30,
                ),
                backButton(context),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Events",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ),
            eventsSection(
                widget.userProvider, widget.metamaskProvider, widget, context)
          ],
        ),
      ),
    );
  }
}
