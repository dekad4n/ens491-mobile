import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/models/user_model.dart';
import 'package:tickrypt/pages/mint_ticket_page.dart';
import 'package:tickrypt/pages/event_page.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:tickrypt/services/user.dart';
import 'package:tickrypt/services/utils.dart';
import 'package:tickrypt/widgets/navbars.dart';

import 'package:tickrypt/widgets/atoms/sliders/horizontal_slider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  UtilsService utilsService = UtilsService();
  UserService userService = UserService();

  bannerContainer() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: NetworkImage(
                "https://png.pngtree.com/thumb_back/fh260/back_our/20190614/ourmid/pngtree-three-dimensional-texture-fashion-concert-poster-background-material-image_122060.jpg"),
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter),
        color: Colors.grey,
      ),
      padding: EdgeInsets.all(20),
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Featured",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              SizedBox(height: 5),
              Text(
                "Find the recent events!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.purple,
                    elevation: 15,
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () => {},
                  child: Text(
                    "Check it out   ",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w900),
                  ))
            ],
          )
        ],
      ),
    );
  }

  Future<List<Card>> getEvents(userProvider, metamaskProvider) async {
    String searchTitle = "";
    String id = "";
    int page = 1;
    int pageLimit = 10;

    List<Event> events =
        await utilsService.search(searchTitle, id, page, pageLimit);

    List<Card> eventCards = [];

    for (Event e in events) {
      Card eventCard =
          await horizontalEventCard(e, userProvider, metamaskProvider);
      eventCards.add(eventCard);
    }
    return eventCards;
  }

  Future<Card> horizontalEventCard(
      Event e, userProvider, metamaskProvider) async {
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

  eventsSection(userProvider, metamaskProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "Events",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          Divider(
            thickness: 1,
          ),
          FutureBuilder(
            future: getEvents(userProvider, metamaskProvider),
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

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    var metamaskProvider = Provider.of<MetamaskProvider>(context);

    return (Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ElevatedButton(
              //   onPressed: () async {
              //     String searchTitle = "banana";
              //     String id = "";
              //     int page = 1;
              //     int pageLimit = 10;

              //     List<Event> events =
              //         await utilsService.search(searchTitle, id, page, pageLimit);

              //     events.forEach((element) {
              //       print(element.title);
              //     });
              //   },
              //   child: Text("SEARCH"),
              // ),
              // carouselSlider([
              //   {
              //     "url":
              //         "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg"
              //   },
              //   {
              //     "url":
              //         "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg"
              //   }
              // ])
              bannerContainer(),
              SizedBox(height: 30),
              eventsSection(userProvider, metamaskProvider),
            ],
          ),
        ),
      ),
    ));
  }
}
