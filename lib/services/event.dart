import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:tickrypt/models/event_model.dart';

class EventService {
  var backendUrl = dotenv.env["BACKEND_URL"];

  Future<Event> getEventById(String eventId) async {
    final String url = '${backendUrl}/event?id=$eventId';

    Response res = await get(Uri.parse(url));

    var body = jsonDecode(res.body);

    Event event = Event.fromJson(body["event"]);

    return event;
  }

  Future<Event> createEvent(eventProps, auth) async {
    final String url = '${backendUrl!}/event/create';

    var headers = {
      "Access-Control-Allow-Origin": '*',
      "Authorization": "jwt $auth",
    };

    Response res = await post(
      Uri.parse(url),
      body: eventProps,
      headers: headers,
    );

    var body = jsonDecode(res.body);

    Event event = Event.fromJson(body["event"]);

    return event;
  }
}
