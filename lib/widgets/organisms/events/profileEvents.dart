import 'package:flutter/material.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/pages/create_event.dart';
import 'package:tickrypt/widgets/molecules/cards/vertical_event_card.dart';

Container profileEvents(
    BuildContext context, List<Event> events, userProvider, setState) {
  return Container(
    color: const Color(0xFFe9f2f6),
    width: MediaQuery.of(context).size.width,
    alignment: Alignment.topLeft,
    padding: const EdgeInsets.fromLTRB(24, 37, 15, 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      // ignore: prefer_const_literals_to_create_immutables
      children: [
        // ignore: prefer_const_constructors
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "My Events (${events.length})",
              // ignore: prefer_const_constructors
              style: TextStyle(
                  color: const Color(0xFF050A31),
                  fontSize: 20,
                  fontFamily: 'Avenir',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1),
            ),
            ElevatedButton(
              onPressed: () {
                // Go to createEvent page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CreateEvent(userProvider: userProvider)),
                ).then((value) => {setState(() {})});
              },
              child: Icon(Icons.add, color: Colors.white),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(8),
                backgroundColor: const Color(0xFF050A31), // <-- Button color
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Container(
            width: MediaQuery.of(context).size.width - 39,
            height: (MediaQuery.of(context).size.width - 39) * 258 / 330,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (var event in events)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: verticalEventCard(context, event),
                  ),
                if (events.length == 0)
                  Container(
                      alignment: Alignment.topCenter,
                      width: MediaQuery.of(context).size.width - 39,
                      child: Text(
                        "Nothing to see here.",
                        style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w900,
                            color: const Color(0x000000).withOpacity(0.5)),
                      ))
              ],
            ),
          ),
        )
      ],
    ),
  );
}
