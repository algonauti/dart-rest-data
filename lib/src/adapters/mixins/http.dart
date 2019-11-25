import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../exceptions.dart';

mixin Http {
  String hostname;
  var headers = Map<String, String>();

  String checkAndDecode(http.Response response) {
    http.Request request = response.request;
    String method = request.method;
    String url = request.url.toString();
    int code = response.statusCode;
    String responseBody = response.body;
    String requestBody = request.body;
    if (code == 200) {
      try {
        return utf8.decode(response.bodyBytes);
      } on FormatException {
        throw InvalidDataReceived();
      }
    } else if (code == 204)
      return null;
    else if (code == 400)
      throw BadRequestException(method, url, requestBody, responseBody);
    else if (code == 401)
      throw UnauthorizedException(method, url);
    else if (code == 403)
      throw ForbiddenException(method, url);
    else if (code == 404)
      throw NotFoundException(method, url);
    else if (code == 422)
      throw UnprocessableException(method, url, requestBody, responseBody);
    else if (code > 400 && code < 500)
      throw ClientError(method, url, code, requestBody, responseBody);
    else if (code >= 500 && code <= 599)
      throw ServerError(method, url, code, requestBody, responseBody);
    else {
      throw HttpStatusException(
        method,
        url,
        statusCode: code,
        requestBody: requestBody,
        responseBody: responseBody,
      );
    }
  }

  void addHeader(name, value) {
    headers[name] = value;
  }

  Future<http.Response> httpGet(
    String path, {
    Map<String, String> queryParams,
  }) async {
    return await _safelyRun(() async {
      var url = Uri.https(hostname, path, queryParams);
      return await http.get(url, headers: headers);
    });
  }

  Future<http.Response> httpPost(String path, {String body}) async {
    return await _safelyRun(() async {
      var url = Uri.https(hostname, path);
      return await http.post(url, headers: headers, body: body);
    });
  }

  Future<http.Response> httpPatch(String path, {String body}) async {
    return await _safelyRun(() async {
      var url = Uri.https(hostname, path);
      return await http.patch(url, headers: headers, body: body);
    });
  }

  Future<http.Response> httpPut(String path, {String body}) async {
    return await _safelyRun(() async {
      var url = Uri.https(hostname, path);
      return await http.put(url, headers: headers, body: body);
    });
  }

  Future<http.Response> httpDelete(String path) async {
    return await _safelyRun(() async {
      var url = Uri.https(hostname, path);
      return await http.delete(url, headers: headers);
    });
  }

  Future<http.Response> _safelyRun(Future<http.Response> method()) async {
    try {
      return await method();
    } on SocketException {
      throw NoNetworkError();
    } on http.ClientException {
      throw NetworkError();
    } on TlsException {
      throw NetworkError();
    }
  }
}
