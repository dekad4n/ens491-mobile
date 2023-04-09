import 'dart:convert';
import 'package:http/http.dart';

class LocationService {
  getCountries(String filter) async {
    String url = "https://restcountries.com/v3.1/";

    if (filter != "") {
      url += "name/{$filter}?fields=name";
    } else {
      url += "all?fields=name";
    }
    Response res = await get(Uri.parse(url));
    print(res);
    return res.body;
  }

  getCitiesByCountry() {
    
  }
}
