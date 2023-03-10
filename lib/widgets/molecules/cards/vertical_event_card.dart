import 'package:provider/provider.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:tickrypt/services/event.dart';
import 'package:tickrypt/widgets/atoms/imageWrappers/vertical_event_image_wrapper.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tickrypt/pages/event_page.dart';

GestureDetector verticalEventCard(BuildContext context, Event event) {
  var userProvider = Provider.of<UserProvider>(context);
  var metamaskProvider = Provider.of<MetamaskProvider>(context);

  EventService eventService = EventService();

  DateTime date = DateTime.parse(event.startDate!);
  String day = DateFormat('EEEE').format(date).substring(0, 3);
  String formattedDate = day + DateFormat(', MMMM d').format(date);
  String time = event.startTime!;
  return GestureDetector(
    onTap: () async {
      await eventService.getEventById(event.id!);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EventPage(
                    event: event,
                    userProvider: userProvider,
                    metamaskProvider: metamaskProvider,
                  )));
    },
    behavior: HitTestBehavior.opaque,
    child: Container(
      alignment: Alignment.topLeft,
      width: (MediaQuery.of(context).size.width - 47) / 2,
      height: (MediaQuery.of(context).size.width - 47) * 258 / 330,
      decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              offset: Offset(-2, 2),
              blurRadius: 10,
              color: Color.fromRGBO(5, 10, 49, 0.1),
            ),
          ],
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalEventImageWrapper(context, event.coverImageURL),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title!,
                  style: const TextStyle(
                      color: Color(0xFF050A31),
                      fontFamily: 'Avenir',
                      fontSize: 19,
                      fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      "Event id: ",
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      event.integerId.toString() ?? "N/A",
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                )
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            child: Text(
              formattedDate,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Color(0xFF050A31),
                fontFamily: 'Avenir',
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0, 10, 17),
            child: Text(
              time ?? "",
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Color(0xFF050A31),
                fontFamily: 'Avenir',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
