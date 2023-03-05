import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:tickrypt/models/event_model.dart';

class EventService {
  // var backendUrl = dotenv.env["BACKEND_URL"];
  var backendUrl = "http://10.51.20.179:3001";

  Future<Event> getEventById(String eventId) async {
    final String url = '${backendUrl}/event?id=$eventId';

    Response res = await get(Uri.parse(url));

    var body = jsonDecode(res.body);

    Event event = Event.fromJson(body["event"]);

    return event;
  }

  Future<Event> createEvent() async {
    final String url = '${backendUrl!}/event/create';
    Response res = await post(Uri.parse(url));

    var body = jsonDecode(res.body);

    Event event = Event.fromJson(body["event"]);

    return event;
  }
}
