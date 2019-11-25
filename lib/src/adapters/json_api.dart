import './mixins/http.dart';
import '../exceptions.dart';
import '../interfaces.dart';
import '../serializers/json_api.dart';

class JsonApiAdapter extends Adapter with Http {
  String apiPath;
  Map<String, Map<String, JsonApiDocument>> _cache;

  JsonApiAdapter(hostname, this.apiPath) : super(JsonApiSerializer()) {
    this.hostname = hostname;
    _cache = Map<String, Map<String, JsonApiDocument>>();
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
  Future<JsonApiManyDocument> findMany(String endpoint, Iterable<String> ids,
      {bool forceReload = false}) async {
    if (forceReload == true) return await query(endpoint, _idsParam(ids));
    JsonApiManyDocument cached = peekMany(endpoint, ids);
    if (cached.length != ids.length) {
      List<JsonApiDocument> cachedDocs = cached.toList();
      Iterable<String> cachedIds = cachedDocs.map((doc) => doc.id);
      Iterable<String> loadableIds = ids.where((id) => !cachedIds.contains(id));
      JsonApiManyDocument loaded =
          await query(endpoint, _idsParam(loadableIds));
      if (cachedDocs.isNotEmpty) loaded.append(cachedDocs);
      return loaded;
    } else
      return cached;
  }

  Map<String, String> _idsParam(Iterable<String> ids) {
    return {'filter[id]': ids.join(',')};
  }

  @override
  Future<JsonApiManyDocument> findAll(String endpoint) async {
    final response = await httpGet("$apiPath/$endpoint");
    String payload = checkAndDecode(response);
    return _deserializeAndCacheMany(payload, endpoint);
  }

  @override
  Future<JsonApiManyDocument> query(
      String endpoint, Map<String, String> params) async {
    final response = await httpGet("$apiPath/$endpoint", queryParams: params);
    String payload = checkAndDecode(response);
    return _deserializeAndCacheMany(payload, endpoint);
  }

  JsonApiManyDocument _deserializeAndCacheMany(
      String payload, String endpoint) {
    JsonApiManyDocument fetched = serializer.deserializeMany(payload);
    cacheMany(endpoint, fetched);
    return fetched;
  }

  @override
  Future<JsonApiDocument> save(String endpoint, Object document) async {
    if (document is! JsonApiDocument) {
      throw ArgumentError('document must be a JsonApiDocument');
    }
    JsonApiDocument jsonApiDoc;
    try {
      jsonApiDoc = (document as JsonApiDocument);
      var response;
      if (jsonApiDoc.isNew) {
        response = await httpPost("$apiPath/$endpoint",
            body: serializer.serialize(jsonApiDoc));
      } else {
        response = await httpPatch("$apiPath/$endpoint/${jsonApiDoc.id}",
            body: serializer.serialize(jsonApiDoc));
      }
      String payload = checkAndDecode(response);
      JsonApiDocument saved = serializer.deserialize(payload);
      cache(endpoint, saved);
      return saved;
    } on UnprocessableException catch (e) {
      Map parsed = (serializer as JsonApiSerializer).parse(e.responseBody);
      if (parsed.containsKey('errors')) {
        jsonApiDoc.errors = parsed['errors'];
        throw InvalidRecordException();
      } else {
        throw e;
      }
    }
  }

  @override
  Future<void> delete(String endpoint, Object document) async {
    try {
      unCache(endpoint, document);
      JsonApiDocument jsonApiDoc = (document as JsonApiDocument);
      final response = await httpDelete("$apiPath/$endpoint/${jsonApiDoc.id}");
      checkAndDecode(response);
    } on CastError {
      throw ArgumentError('document must be a JsonApiDocument');
    }
  }

  @override
  Future<JsonApiDocument> memberPutAction(
      String endpoint, Object document, String actionPath) async {
    if (document is! JsonApiDocument) {
      throw ArgumentError('document must be a JsonApiDocument');
    }
    JsonApiDocument jsonApiDoc;
    try {
      jsonApiDoc = (document as JsonApiDocument);
      var response = await httpPut(
        "$apiPath/$endpoint/${jsonApiDoc.id}/$actionPath",
        body: serializer.serialize(jsonApiDoc),
      );
      String payload = checkAndDecode(response);
      JsonApiDocument updated = serializer.deserialize(payload);
      cache(endpoint, updated);
      return updated;
    } on UnprocessableException catch (e) {
      Map parsed = (serializer as JsonApiSerializer).parse(e.responseBody);
      if (parsed.containsKey('errors')) {
        jsonApiDoc.errors = parsed['errors'];
        throw InvalidRecordException();
      } else {
        throw e;
      }
    }
  }

  @override
  void cache(String endpoint, Object document) {
    try {
      JsonApiDocument jsonApiDoc = (document as JsonApiDocument);
      _cache[endpoint] ??= Map<String, JsonApiDocument>();
      _cache[endpoint][jsonApiDoc.id] = jsonApiDoc;
    } on CastError {
      throw ArgumentError('document must be a JsonApiDocument');
    }
  }

  @override
  void unCache(String endpoint, Object document) {
    try {
      JsonApiDocument jsonApiDoc = (document as JsonApiDocument);
      Map<String, JsonApiDocument> docCache = _cache[endpoint];
      if (docCache != null && docCache.containsKey(jsonApiDoc.id))
        docCache.remove(jsonApiDoc.id);
    } on CastError {
      throw ArgumentError('document must be a JsonApiDocument');
    }
  }

  @override
  void clearCache() {
    _cache.values.forEach((docCache) {
      if (docCache is Map) docCache.clear();
    });
    _cache.clear();
  }

  @override
  void cacheMany(String endpoint, Iterable<Object> documents) {
    documents.forEach((document) => cache(endpoint, document));
  }

  @override
  JsonApiDocument peek(String endpoint, String id) {
    Map<String, JsonApiDocument> docCache = _cache[endpoint];
    return docCache != null ? docCache[id] : null;
  }

  @override
  JsonApiManyDocument peekMany(String endpoint, Iterable<String> ids) =>
      JsonApiManyDocument(
          ids.map((id) => peek(endpoint, id)).where((doc) => doc != null));

  @override
  JsonApiManyDocument peekAll(String endpoint) {
    Map<String, JsonApiDocument> docCache = _cache[endpoint];
    return JsonApiManyDocument(
        docCache != null ? docCache.values : List<JsonApiDocument>());
  }
}
