class InvalidRecordException implements Exception {}

class SerializationException implements Exception {}

class DeserializationException implements Exception {}

class HttpStatusException implements Exception {
  String method;
  String url;
  String? responseBody;
  String? requestBody;
  int? statusCode;

  HttpStatusException(
    this.method,
    this.url, {
    this.statusCode,
    this.requestBody,
    this.responseBody,
  });

  @override
  String toString() =>
      "HTTP error: $method $url\n\n$requestBody\n$responseBody";
}

class BadRequestException extends HttpStatusException {
  BadRequestException(
    String method,
    String url,
    String requestBody,
    String responseBody,
  ) : super(method, url, requestBody: requestBody, responseBody: responseBody);

  @override
  String toString() =>
      "Bad request: $method $url\n\n$requestBody\n$responseBody";
}

class ForbiddenException extends HttpStatusException {
  ForbiddenException(String method, String url) : super(method, url);

  @override
  String toString() => "Forbidden request: $method $url";
}

class UnauthorizedException extends HttpStatusException {
  UnauthorizedException(String method, String url) : super(method, url);

  @override
  String toString() => "Unauthorized request: $method $url";
}

class NotFoundException extends HttpStatusException {
  NotFoundException(String method, String url) : super(method, url);

  @override
  String toString() => "Resource not found: $method $url";
}

class UnprocessableException extends HttpStatusException {
  UnprocessableException(
    String method,
    String url,
    String requestBody,
    String responseBody,
  ) : super(method, url, requestBody: requestBody, responseBody: responseBody);

  @override
  String toString() =>
      "Unprocessable request: $method $url\n\n$requestBody\n$responseBody";
}

class ClientError extends HttpStatusException {
  ClientError(
    String method,
    String url,
    int statusCode,
    String requestBody,
    String responseBody,
  ) : super(
          method,
          url,
          statusCode: statusCode,
          requestBody: requestBody,
          responseBody: responseBody,
        );

  @override
  String toString() =>
      "Client request error: $method $url\n\n$requestBody\n$responseBody";
}

class ServerError extends HttpStatusException {
  ServerError(
    String method,
    String url,
    int statusCode,
    String requestBody,
    String responseBody,
  ) : super(
          method,
          url,
          statusCode: statusCode,
          requestBody: requestBody,
          responseBody: responseBody,
        );

  @override
  String toString() =>
      "Server processing error: $method $url\n\n$requestBody\n$responseBody";
}

class NetworkError implements Exception {}

class NoNetworkError implements Exception {}

class InvalidDataReceived implements Exception {}

class _ExceptionWithMessage implements Exception {
  String message;

  _ExceptionWithMessage(this.message);

  String toString() => '${this.runtimeType}: ${this.message}';
}

class CachingException extends _ExceptionWithMessage {
  CachingException(String message) : super(message);
}

class DataStructureException extends _ExceptionWithMessage {
  DataStructureException(String message) : super(message);
}
