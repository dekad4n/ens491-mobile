import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:tickrypt/models/event_model.dart';

class UtilsService {
  var backendUrl = dotenv.env["BACKEND_URL"];

  Future<List<Event>> search(
      String searchTitle, String id, int page, int pageLimit) async {
    // let { search, id, page, pageLimit } = req.query;
    String url = '${backendUrl}/utils/search';

    if (searchTitle != "" && id == "") {
      url += "?searchTitle=$searchTitle";
    } else if (id != "" && searchTitle == "") {
      url += "?id=$id";
    } else {
      url += "?searchTitle=$searchTitle&id=$id";
    }

    url += "&page=" + page.toString();

    Response res = await get(Uri.parse(url));
    var body = jsonDecode(res.body);

    List<Event> events = [...body["events"].map((i) => Event.fromJson(i))];

    return events;
  }

  Future<List<Event>> getEventsByCategory(String category) async {
    final String url =
        '${backendUrl}/utils/get-events-by-category?category=$category';
    ;
    Response res = await get(Uri.parse(url));
    var body = jsonDecode(res.body);
    List<Event> events = [...body.map((i) => Event.fromJson(i))];
    return events;
  }
}
