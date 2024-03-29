import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart';

class TicketService {
  var backendUrl = dotenv.env["BACKEND_URL"];
  var headers = {
    "Access-Control-Allow-Origin": '*',
  };

  Future<dynamic> mint({
    auth,
    eventId,
    amount,
    startDateTime,
    endDateTime,
  }) async {
    var user = {
      "_id": "63a305d83cff9d2414c9fafe",
      "id": "0x243aec942e214a4b78e625fab53c8f9ae7dc98c8",
      "username": "0x243aec942e214a4b78e625fab53c8f9ae7dc98c8",
      "nonce": "c90cddc2-f287-4064-8380-47315edfe4b6",
      "__v": 0
    };
    var image =
        "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";

    // All params should be string
    var params = {
      "name": "ticketNameHere",
      "image": image,
      "eventId": eventId.toString(),
      "amount": amount.toString(),
      "startDateTime": startDateTime,
      "endDateTime": endDateTime,
    };

    headers["Authorization"] = "jwt $auth";

    final String authUrl = '${backendUrl!}/ticket/mint';

    try {
      Response res =
          await post(Uri.parse(authUrl), body: params, headers: headers);

      var body = jsonDecode(res.body);

      return body;
    } catch (e) {
      print("Error during mint():" + e.toString());
    }
  }

  Future<dynamic> getTicketDetails({ticketToken}) async {
    final String authUrl = '${backendUrl!}/ticket?token=$ticketToken';

    try {
      Response res = await get(
        Uri.parse(authUrl),
        headers: headers,
      );

      var body = jsonDecode(res.body);

      return body["result"];
      //It will return the following map:
      // {name: "sadi", image: "ipfs://123456"}

      // return body;
    } catch (e) {
      print("Error during getTicket():" + e.toString());
    }
  }

  Future<dynamic> getTicketCheckedInfo(tokenId, nonce, signature, auth) async {
    final String url = '${backendUrl!}/ticket/is-ticket-checked';

    var headers = {
      "Access-Control-Allow-Origin": '*',
      "Authorization": "jwt $auth",
    };

    Map<String, dynamic> params = {
      "tokenId": tokenId,
      "nonce": nonce,
      "signature": signature
    };

    Response res = await post(
      Uri.parse(url),
      body: params,
      headers: headers,
    );
    var body = jsonDecode(res.body);
    return body;
  }

  Future<dynamic> changeTicketUsedState(auth, eventId) async {
    final String url = '${backendUrl!}/ticket/change-ticket-used-state';

    var headers = {
      "Access-Control-Allow-Origin": '*',
      "Authorization": "jwt $auth",
    };

    Map<String, dynamic> params = {
      "eventID": eventId.toString(),
    };
    print("here1");
    Response res = await post(
      Uri.parse(url),
      body: params,
      headers: headers,
    );
    print("here2");
    var body = jsonDecode(res.body);
    print("here");
    return body;
  }
}
