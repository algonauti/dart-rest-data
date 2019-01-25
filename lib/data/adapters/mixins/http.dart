import 'dart:convert';

import 'package:http/http.dart' as http;

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

  Future<http.Response> httpGet(String path,
      {Map<String, String> queryParams}) async {
    var url = Uri.https(hostname, path, queryParams);
    return await http.get(url, headers: headers);
  }

  Future<http.Response> httpPost(String path, {String body}) async {
    var url = Uri.https(hostname, path);
    return await http.post(url, headers: headers, body: body);
  }

  Future<http.Response> httpPatch(String path, {String body}) async {
    var url = Uri.https(hostname, path);
    return await http.patch(url, headers: headers, body: body);
  }
}
