import 'package:cinderblock/data/adapters/mixins/http.dart';
import 'package:cinderblock/data/exceptions.dart';
import 'package:cinderblock/data/interfaces.dart';
import 'package:cinderblock/data/serializers/json_api.dart';

class JsonApiAdapter extends Adapter with Http {
  String apiPath;
  Map<String, JsonApiDocument> _cache;

  JsonApiAdapter(hostname, this.apiPath) : super(JsonApiSerializer()) {
    this.hostname = hostname;
    _cache = Map<String, JsonApiDocument>();
    addHeader('Content-Type', 'application/json; charset=utf-8');
  }

  @override
  Future<JsonApiDocument> find(String endpoint, String id,
      {bool forceReload = false}) async {
    if (forceReload == true) return _fetchAndCache(endpoint, id);
    JsonApiDocument cached = peek(endpoint, id);
    if (cached != null)
      return cached;
    else
      return _fetchAndCache(endpoint, id);
  }

  Future<JsonApiDocument> _fetchAndCache(String endpoint, String id) async {
    JsonApiDocument fetched = await _fetch(endpoint, id);
    cache(endpoint, fetched);
    return fetched;
  }

  Future<JsonApiDocument> _fetch(String endpoint, String id) async {
    final response = await httpGet("$apiPath/$endpoint/$id");
    String payload = checkAndDecode(response);
    return serializer.deserialize(payload);
  }

  @override
  Future<Iterable<JsonApiDocument>> findMany(
      String endpoint, Iterable<String> ids,
      {bool forceReload = false}) async {
    if (forceReload == true) return await query(endpoint, _idsParam(ids));
    List<JsonApiDocument> cached = peekMany(endpoint, ids).toList();
    if (cached.length != ids.length) {
      List<String> cachedIds = cached.map((doc) => doc.id);
      Iterable<String> loadableIds = ids.where((id) => !cachedIds.contains(id));
      cached.addAll(await query(endpoint, _idsParam(loadableIds)));
    }
    return cached;
  }

  Map<String, String> _idsParam(Iterable<String> ids) {
    return {'filter[id]': ids.join(',')};
  }

  @override
  Future<Iterable<JsonApiDocument>> findAll(String endpoint) async {
    final response = await httpGet("$apiPath/$endpoint");
    String payload = checkAndDecode(response);
    return serializer.deserializeMany(payload);
  }

  @override
  Future<Iterable<JsonApiDocument>> query(
      String endpoint, Map<String, String> params) async {
    final response = await httpGet("$apiPath/$endpoint", queryParams: params);
    String payload = checkAndDecode(response);
    Iterable<JsonApiDocument> fetched = serializer.deserializeMany(payload);
    cacheMany(endpoint, fetched);
    return fetched;
  }

  @override
  Future<JsonApiDocument> save(String endpoint, dynamic document) async {
    if (document is! JsonApiDocument) {
      throw ArgumentError('document must be a JsonApiDocument');
    }
    try {
      var response;
      if (document.isNew) {
        response = await httpPost("$apiPath/$endpoint",
            body: serializer.serialize(document));
      } else {
        response = await httpPatch("$apiPath/$endpoint/${document.id}",
            body: serializer.serialize(document));
      }
      String payload = checkAndDecode(response);
      JsonApiDocument saved = serializer.deserialize(payload);
      cache(endpoint, saved);
      return saved;
    } on UnprocessableException catch (e) {
      Map parsed = (serializer as JsonApiSerializer).parse(e.responseBody);
      if (parsed.containsKey('errors')) {
        document.errors = parsed['errors'];
        throw InvalidRecordException();
      } else {
        throw e;
      }
    }
  }

  @override
  Future<void> delete(String endpoint, Object document) async {
    try {
      JsonApiDocument jsonApiDoc = (document as JsonApiDocument);
      final response = await httpDelete("$apiPath/$endpoint/${jsonApiDoc.id}");
      checkAndDecode(response);
    } on CastError {
      throw ArgumentError('document must be a JsonApiDocument');
    }
  }

  @override
  void cache(String endpoint, Object document) {
    try {
      JsonApiDocument jsonApiDoc = (document as JsonApiDocument);
      _cache["$endpoint:${jsonApiDoc.id}"] = jsonApiDoc;
    } on CastError {
      throw ArgumentError('document must be a JsonApiDocument');
    }
  }

  @override
  void unCache(String endpoint, Object document) {
    try {
      JsonApiDocument jsonApiDoc = (document as JsonApiDocument);
      _cache.remove("$endpoint:${jsonApiDoc.id}");
    } on CastError {
      throw ArgumentError('document must be a JsonApiDocument');
    }
  }

  @override
  void cacheMany(String endpoint, Iterable<Object> documents) {
    documents.forEach((document) => cache(endpoint, document));
  }

  @override
  JsonApiDocument peek(String endpoint, String id) {
    return _cache["$endpoint:$id"];
  }

  @override
  Iterable<JsonApiDocument> peekMany(String endpoint, Iterable<String> ids) {
    return ids.map((id) => peek(endpoint, id)).where((doc) => doc != null);
  }
}
