import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart';

class AuctionService {
  var backendUrl = dotenv.env["BACKEND_URL"];

  final headers = {
    'Access-Control-Allow-Origin': '*',
    'Content-Type': 'application/json',
  };

  Future<List<dynamic>> getOngoingAuctions(eventId) async {
    String url = '${backendUrl!}/auction/ongoing/${eventId}';

    Response res = await get(Uri.parse(url), headers: headers);

    var body = jsonDecode(res.body);

    return body;
  }

  dynamic createBidItem(ticketId, eventId, startPrice, time, auth) async {
    final String authUrl = '${backendUrl!}/auction/create-bid-item';
    try {
      Response res = await post(Uri.parse(authUrl),
          body: jsonEncode({
            "ticketId": ticketId,
            "eventId": eventId,
            "startPrice": startPrice,
            "time": time
          }),
          headers: {"Authorization": "jwt $auth", ...headers});
      var body = jsonDecode(res.body);
      return body;
    } catch (e) {}
  }

  dynamic stopAuction(auctionId, auth) async {
    final String authUrl = '${backendUrl!}/auction/stop-auction';
    try {
      Response res = await post(Uri.parse(authUrl),
          body: jsonEncode({
            "auctionId": auctionId,
          }),
          headers: {"Authorization": "jwt $auth", ...headers});
      var body = jsonDecode(res.body);
      return body;
    } catch (e) {}
  }

  dynamic getAuctionInfo(auctionId) async {
    final String authUrl =
        '${backendUrl!}/auction/get-auction?auctionId=${auctionId}';

    Response res = await get(Uri.parse(authUrl), headers: headers);
    var body = jsonDecode(res.body);

    return body;
  }

  dynamic placeBid(auctionId, price, auth) async {
    final String authUrl = '${backendUrl!}/auction/bid';
    try {
      Response res = await post(Uri.parse(authUrl),
          body: jsonEncode({"auctionId": auctionId, "bidPrice": price}),
          headers: {"Authorization": "jwt $auth", ...headers});
      var body = jsonDecode(res.body);
      return body;
    } catch (e) {}
  }

  dynamic finishBid(auctionId, auth) async {
    final String authUrl = '${backendUrl!}/auction/finish-bid';
    try {
      Response res = await post(Uri.parse(authUrl),
          body: jsonEncode({
            "auctionId": auctionId,
          }),
          headers: {"Authorization": "jwt $auth", ...headers});
      var body = jsonDecode(res.body);
      return body;
    } catch (e) {}
  }

  dynamic paybackPrevBids(auctionId, auth) async {
    final String authUrl = '${backendUrl!}/auction/payback-prev-bids';
    try {
      Response res = await post(Uri.parse(authUrl),
          body: jsonEncode({
            "auctionId": auctionId,
          }),
          headers: {"Authorization": "jwt $auth", ...headers});
      var body = jsonDecode(res.body);
      return body;
    } catch (e) {}
  }

  dynamic listPrevBids(auctionId, auth) async {
    final String authUrl =
        '${backendUrl!}/auction/list-prev-bids?auctionId=${auctionId}';

    Response res = await get(Uri.parse(authUrl),
        headers: {"Authorization": "jyw $auth", ...headers});
    var body = jsonDecode(res.body);
    return body;
  }
}
