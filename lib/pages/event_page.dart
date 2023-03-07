import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tickrypt/models/user_model.dart';
import 'package:tickrypt/pages/create_ticket.dart';
import 'package:tickrypt/services/user.dart';
import 'package:tickrypt/widgets/atoms/buttons/backButtonWhite.dart';

class EventPage extends StatefulWidget {
  final dynamic event;
  const EventPage({super.key, this.event});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  late Future<User> owner;
  UserService userService = UserService();
  void getOwner() {
    setState(() {
      owner = userService.getNonce(widget.event.owner);
    });
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
                        Color.fromRGBO(5, 10, 49, 0.8),
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
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width * 0.05,
                              75,
                              MediaQuery.of(context).size.width * 0.05,
                              0),
                          child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CreateTicket(
                                            props: widget.event.integerId)));
                              },
                              icon: Icon(
                                CupertinoIcons.add_circled,
                                size: 33,
                                color: Colors.white,
                              )),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                    bottom: 40,
                    left: 20,
                    child: Text(
                      widget.event.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 28),
                    ))
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF050A31),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(-5, -20),
                    blurRadius: 10,
                    color: Color.fromRGBO(5, 10, 49, 0.8),
                  ),
                ],
              ),
            ),
            FutureBuilder<User>(
                future: owner,
                builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                  print(snapshot);
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
          ],
        ),
      ),
    );
  }
}
