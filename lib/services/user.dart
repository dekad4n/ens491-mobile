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
    print("asf");
    final String userUrl = '${backendUrl!}/user?publicAdress=$publicAdress';
    Response res = await get(Uri.parse(userUrl));
    print("asf1");

    var body = jsonDecode(res.body);
    print("asf2");

    User user = User.fromJson(body["user"]);
    print("as3");

    return user;
  }
}
