import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:tickrypt/models/user_model.dart';

class UserService {
  var backendUrl = dotenv.env["BACKEND_URL"];
  final headers = {
    'Access-Control-Allow-Origin': '*',
    'Content-Type': 'application/json',
  };
  Future<User> getNonce(publicAdress) async {
    final String userUrl = '${backendUrl!}/user?publicAddress=$publicAdress';
    Response res = await get(Uri.parse(userUrl));

    var body = jsonDecode(res.body);

    User user = User.fromJson(body["user"]);

    return user;
  }
}
