import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/pages/event_page.dart';
import 'package:tickrypt/services/user.dart';
import 'package:tickrypt/services/utils.dart';
import 'package:tickrypt/widgets/molecules/cards/vertical_event_card.dart';
import 'package:tickrypt/widgets/navbars.dart';

import '../models/user_model.dart';
import '../providers/user_provider.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  UserService userService = UserService();
  UtilsService utilsService = UtilsService();
  final scrollController = ScrollController();
  var _searchText = "";
  var page = 1;
  List<Event> searchResultEventList = [];
  Future<void> onSearch(_searchText) async {
    page = 1;
    List<Event> res = await utilsService.search(_searchText, "", page, 10);
    setState(() {
      searchResultEventList = res;
    });
  }

  Future<void> onScroll(_searchText) async {
    List<Event> res = await utilsService.search(_searchText, "", page, 10);
    print("res");
    if (res.length == 0) {
      page = 999;
    }
    setState(() {
      searchResultEventList = searchResultEventList + res;
    });
  }

  Future<User> getOwner(publicAddress) async {
    var res = await userService.getNonce(publicAddress);
    return res;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        // fetch new data and update the list
        if (page == 999) {
          return;
        }
        page += 1;

        print(page);
        onScroll(_searchText);
      }
    });
  }

  Card horizontalEventCard(Event e, userProvider, User owner) {
    //Get owner username and avatar
    String? ownerUsername = owner.username;
    String? ownerAvatar = owner.avatar;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
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

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    return (Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 2, 10, 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 0.3, color: Color(0xFF5200FF)),
              ),
              child: TextFormField(
                decoration: InputDecoration(
                    hintText: 'Enter event name', border: InputBorder.none),
                onChanged: (value) async {
                  _searchText = value;
                  if (_searchText.length > 3) {
                    onSearch(_searchText);
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: searchResultEventList.length,
              itemBuilder: (BuildContext context, int index) {
                return FutureBuilder(
                  future: getOwner(searchResultEventList[index].owner),
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
                        return horizontalEventCard(searchResultEventList[index],
                            userProvider, snapshot.data!);
                      }
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
              },
            ),
          )
        ]),
      ),
    ));
  }
}
