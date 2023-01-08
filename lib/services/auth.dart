import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart';

class AuthService {
  var backendUrl = dotenv.env["BACKEND_URL"];
  final headers = {
    'Access-Control-Allow-Origin': '*',
    'Content-Type': 'application/json',
  };
  dynamic login(nonce, signature) async {
    final String authUrl = '${backendUrl!}/auth/login';
    try {
      Response res = await post(Uri.parse(authUrl),
          body: jsonEncode({"nonce": nonce, "signature": signature}),
          headers: headers);
      var body = jsonDecode(res.body);
      return body;
    } catch (e) {}
  }
}
