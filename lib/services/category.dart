import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/models/category_model.dart';

class CategoryService {
  var backendUrl = dotenv.env["BACKEND_URL"];

  Future<List<Category>> getAllCategories() async {
    String url = '${backendUrl}/category/get-all';
    Response res = await get(Uri.parse(url));
    var body = jsonDecode(res.body);
    List<Category> category = [...body.map((i) => Category.fromJson(i))];

    return category;
  }
}
