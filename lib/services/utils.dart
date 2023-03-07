import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:tickrypt/models/event_model.dart';

class UtilsService {
  // var backendUrl = dotenv.env["BACKEND_URL"];
  var backendUrl = "http://10.51.20.179:3001";

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

    Response res = await get(Uri.parse(url));
    var body = jsonDecode(res.body);

    List<Event> events = [...body["events"].map((i) => Event.fromJson(i))];

    return events;
  }
}
