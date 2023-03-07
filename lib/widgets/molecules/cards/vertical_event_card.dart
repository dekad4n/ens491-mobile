import 'package:tickrypt/widgets/atoms/imageWrappers/vertical_event_image_wrapper.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tickrypt/pages/event_page.dart';

GestureDetector verticalEventCard(BuildContext context, Event event) {
  DateTime date = DateTime.parse(event.startDate!);
  String day = DateFormat('EEEE').format(date).substring(0, 3);
  String formattedDate = day + DateFormat(', MMMM d').format(date);
  String time = event.startTime!;
  return GestureDetector(
    onTap: () {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => EventPage(event: event)));
    },
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
            child: Text(
              event.title!,
              style: const TextStyle(
                  color: Color(0xFF050A31),
                  fontFamily: 'Avenir',
                  fontSize: 19,
                  fontWeight: FontWeight.w800),
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
