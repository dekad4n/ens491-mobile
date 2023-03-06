import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/models/user_model.dart';

class UserService {
  var backendUrl = dotenv.env["BACKEND_URL"];
  final headers = {
    'Access-Control-Allow-Origin': '*',
    'Content-Type': 'application/json',
  };
  Future<User> getNonce(publicAddress) async {
    final String userUrl = '${backendUrl!}/user?publicAddress=$publicAddress';
    Response res = await get(Uri.parse(userUrl));
    var body = jsonDecode(res.body);
    User user = User.fromJson(body["user"]);
    return user;
  }

  Future<List<Event>> getEvents(publicAddress) async {
    final String eventsUrl =
        '${backendUrl!}/user/events?publicAddress=$publicAddress';

    Response res = await get(Uri.parse(eventsUrl));

    var body = jsonDecode(res.body);
    List<Event> events = [...body.map((i) => Event.fromJson(i))];
    return events;
  }

  Future<dynamic> updateUser(Map<String, dynamic> props, auth) async {
    final String url = '${backendUrl!}/user/update';
    var headers = {
      "Access-Control-Allow-Origin": '*',
      "Authorization": "jwt $auth",
    };
    Response res = await post(
      Uri.parse(url),
      body: props,
      headers: headers,
    );

    var body = jsonDecode(res.body);
    print(body);
  }
}
