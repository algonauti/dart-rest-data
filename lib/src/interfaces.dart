abstract class Serializer {
  String serialize(Object document);
  Object deserialize(String payload);
  Iterable<Object> deserializeMany(String payload);
}

abstract class Adapter {
  Serializer serializer;

  Adapter(this.serializer);

  Future<Object> find(
    String endpoint,
    String id, {
    bool forceReload = false,
    Map<String, String> queryParams,
  });
  Future<Iterable<Object>> findMany(String endpoint, Iterable<String> ids,
      {bool forceReload = false, Map<String, String> queryParams});
  Future<Iterable<Object>> findAll(String endpoint,
      {Map<String, String> queryParams});
  Future<Iterable<Object>> query(String endpoint, Map<String, String> params);
  Future<Object> save(String endpoint, Object document);
  Future<void> delete(String endpoint, Object document);
  Future<Object> memberPutAction(
      String endpoint, Object document, String actionPath);

  void cache(String endpoint, Object document);
  void unCache(String endpoint, Object document);
  void clearCache();
  void cacheMany(String endpoint, Iterable<Object> documents);
  Object? peek(String endpoint, String id);
  Iterable<Object> peekMany(String endpoint, Iterable<String> ids);
  Iterable<Object> peekAll(String endpoint);
}

abstract class Model {
  String? get id;
  String? get type;
  String serialize();
  T getAttribute<T>(String key);
  void setAttribute<T>(String key, T value);
}
