import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:tickrypt/models/event_model.dart';

class MarketService {
  var backendUrl = dotenv.env["BACKEND_URL"];

  Future<List<dynamic>> getMarketItemsAllByEventId(eventId) async {
    final String url =
        '${backendUrl!}/market/market-items-all?eventId=$eventId';

    var headers = {
      "Access-Control-Allow-Origin": '*',
    };

    Response res = await get(
      Uri.parse(url),
      headers: headers,
    );

    var body = jsonDecode(res.body);

    return body["marketItemsAll"];
  }

  Future<List<dynamic>> getMarketItemsOnSaleByEventId(eventId) async {
    final String url =
        '${backendUrl!}/market/market-items-onsale?eventId=$eventId';

    var headers = {
      "Access-Control-Allow-Origin": '*',
    };

    Response res = await get(
      Uri.parse(url),
      headers: headers,
    );

    var body = jsonDecode(res.body);

    return body["marketItemsOnSale"];
  }

  Future<List<dynamic>> getMarketItemsSoldByEventId(eventId) async {
    final String url =
        '${backendUrl!}/market/market-items-sold?eventId=$eventId';

    var headers = {
      "Access-Control-Allow-Origin": '*',
    };

    Response res = await get(
      Uri.parse(url),
      headers: headers,
    );

    var body = jsonDecode(res.body);

    return body["marketItemsSold"];
  }

  Future<dynamic> sell(auth, eventId, price, amount) async {
    final String url = '${backendUrl!}/market/sell';

    var headers = {
      "Access-Control-Allow-Origin": '*',
      "Authorization": "jwt $auth",
    };

    Map<String, dynamic> params = {
      "eventId": eventId.toString(),
      "amount": amount.toString(),
      "price": price.toString(),
    };

    Response res = await post(
      Uri.parse(url),
      body: params,
      headers: headers,
    );

    var body = jsonDecode(res.body);

    return body;
  }
}
