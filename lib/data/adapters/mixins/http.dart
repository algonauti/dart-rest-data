import 'dart:convert';

import 'package:http/http.dart';

mixin Http {
  final Client client = Client();
  String hostname;
  Map<String, String> headers;

  Uri uriFor(String relativePath) {
    return Uri.https(hostname, relativePath);
  }

  String checkAndDecode(Response response) {
    if (response.statusCode == 200) {
      return utf8.decode(response.bodyBytes);
    } else {
      String method = response.request.method;
      String url = response.request.url.toString();
      throw Exception(
          "[$method $url failed] status=${response.statusCode}, body=${response.body}");
    }
  }
}
