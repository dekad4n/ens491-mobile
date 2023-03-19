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

  Future<List<dynamic>> getTransferableIds(auth, eventId, publicAddress) async {
    final String url =
        '${backendUrl!}/market/transferable-ids?eventId=$eventId&publicAddress=$publicAddress';

    var headers = {
      "Access-Control-Allow-Origin": '*',
      "Authorization": "jwt $auth",
    };

    Response res = await get(
      Uri.parse(url),
      headers: headers,
    );

    var body = jsonDecode(res.body);

    return body["transferableIds"];
  }

  Future<dynamic> sell(auth, eventId, price, amount, transferRight) async {
    final String url = '${backendUrl!}/market/sell';

    var headers = {
      "Access-Control-Allow-Origin": '*',
      "Authorization": "jwt $auth",
    };

    Map<String, dynamic> params = {
      "eventId": eventId.toString(),
      "amount": amount.toString(),
      "price": price.toString(),
      "transferRight": transferRight.toString(),
    };

    Response res = await post(
      Uri.parse(url),
      body: params,
      headers: headers,
    );

    var body = jsonDecode(res.body);

    return body;
  }

  Future<dynamic> stopSale(auth, tokenId, price) async {
    final String url = '${backendUrl!}/market/stop-sale';

    var headers = {
      "Accept": "application/json",
      "content-type": "application/json",
      "Access-Control-Allow-Origin": '*',
      "Authorization": "jwt $auth",
    };

    Map<String, dynamic> params = {
      "price": price.toString(),
      "tokenId": tokenId,
    };

    Response res = await post(
      Uri.parse(url),
      body: jsonEncode(params),
      headers: headers,
    );

    var body = jsonDecode(res.body);

    return body;
  }

  Future<dynamic> stopBatchSale(auth, tokenIds, price, eventId) async {
    final String url = '${backendUrl!}/market/stop-batch-sale';

    var headers = {
      "Accept": "application/json",
      "content-type": "application/json",
      "Access-Control-Allow-Origin": '*',
      "Authorization": "jwt $auth",
    };

    Map<String, dynamic> params = {
      "price": price.toString(),
      "tokenIds": tokenIds,
      "eventId": eventId,
    };

    Response res = await post(
      Uri.parse(url),
      body: jsonEncode(params),
      headers: headers,
    );

    var body = jsonDecode(res.body);

    return body;
  }

  Future<dynamic> buyTicket(auth, tokenIds, price) async {
    final String url = '${backendUrl!}/market/buy';

    var headers = {
      "Accept": "application/json",
      "content-type": "application/json",
      "Access-Control-Allow-Origin": '*',
      "Authorization": "jwt $auth",
    };

    Map<String, dynamic> params = {
      "tokenIds": tokenIds,
      "price": price,
    };

    Response res = await post(
      Uri.parse(url),
      body: jsonEncode(params),
      headers: headers,
    );

    var body = jsonDecode(res.body);

    return body;
  }

  Future<dynamic> resell(auth, price, tokenId) async {
    final String url = '${backendUrl!}/market/resell';

    var headers = {
      "Access-Control-Allow-Origin": '*',
      "Authorization": "jwt $auth",
    };

    Map<String, dynamic> params = {
      "price": price.toString(),
      "tokenId": tokenId.toString(),
    };

    Response res = await post(
      Uri.parse(url),
      body: params,
      headers: headers,
    );

    var body = jsonDecode(res.body);

    return body;
  }

  Future<dynamic> resellMultiple(auth, price, tokenIds) async {
    final String url = '${backendUrl!}/market/resell';

    var headers = {
      "Accept": "application/json",
      "content-type": "application/json",
      "Access-Control-Allow-Origin": '*',
      "Authorization": "jwt $auth",
    };

    Map<String, dynamic> params = {
      "price": price.toString(),
      "tokenIds": tokenIds,
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
