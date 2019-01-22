import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

mixin Http {
  String hostname;
  var headers = Map<String, String>();

  String checkAndDecode(http.Response response) {
    if (response.statusCode == 200) {
      return utf8.decode(response.bodyBytes);
    } else {
      String method = response.request.method;
      String url = response.request.url.toString();
      throw Exception(
          "[$method $url failed] status=${response.statusCode}, body=${response.body}");
    }
  }

  void addHeader(name, value) {
    headers[name] = value;
  }

  Future<http.Response> httpGet(
      {@required String path, Map<String, String> queryParams}) async {
    var url = Uri.https(hostname, path, queryParams);
    return await http.get(url, headers: headers);
  }
}
