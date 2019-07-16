import 'dart:convert';

import 'package:http/http.dart' as http;

mixin Http {
  String hostname;
  var headers = Map<String, String>();

  String checkAndDecode(http.Response response) {
    String method = response.request.method;
    String url = response.request.url.toString();
    int code = response.statusCode;
    String body = response.body;
    if (response.statusCode == 200) {
      return utf8.decode(response.bodyBytes);
    } else if (response.statusCode == 204) {
      return null;
    } else if (response.statusCode == 400) {
      throw BadRequestException(method, url);
    } else if (response.statusCode == 403) {
      throw ForbiddenException(method, url);
    } else if (response.statusCode == 404) {
      throw NotFoundException(method, url);
    } else if (response.statusCode == 422) {
      throw UnprocessableException(method, url, body);
    } else {
      throw HttpException(method, url, statusCode: code, responseBody: body);
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

  Future<http.Response> httpPut(String path, {String body}) async {
    var url = Uri.https(hostname, path);
    return await http.put(url, headers: headers, body: body);
  }

  Future<http.Response> httpDelete(String path) async {
    var url = Uri.https(hostname, path);
    return await http.delete(url, headers: headers);
  }
}

class HttpException implements Exception {
  String method;
  String url;
  String responseBody;
  int statusCode;

  HttpException(this.method, this.url, {this.statusCode, this.responseBody});

  @override
  String toString() {
    var msg = "$method $url returned $statusCode";
    if (responseBody != null) msg += " with body: $responseBody";
    return msg;
  }
}

class BadRequestException extends HttpException {
  BadRequestException(String method, String url) : super(method, url);

  @override
  String toString() => "Bad request: $method $url";
}

class ForbiddenException extends HttpException {
  ForbiddenException(String method, String url) : super(method, url);

  @override
  String toString() => "Forbidden request: $method $url";
}

class NotFoundException extends HttpException {
  NotFoundException(String method, String url) : super(method, url);

  @override
  String toString() => "Resource not found: $method $url";
}

class UnprocessableException extends HttpException {
  UnprocessableException(String method, String url, String responseBody)
      : super(method, url, responseBody: responseBody);

  @override
  String toString() => "Unprocessable request: $method $url";
}
