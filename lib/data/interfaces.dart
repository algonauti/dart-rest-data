abstract class Serializer {
  String serialize(Object document);
  Object deserialize(String payload);
  Iterable<Object> deserializeMany(String payload);
}

abstract class Adapter {
  Serializer serializer;

  Adapter(this.serializer);

  Future<Object> find(String endpoint, String id);
  Future<Iterable<Object>> findMany(String endpoint, Iterable<String> ids);
  Future<Iterable<Object>> findAll(String endpoint);
  Future<Iterable<Object>> query(String endpoint, Map<String, String> params);
  Future<Object> save(String endpoint, Object document);
  Future delete(String endpoint, Object document);
}

abstract class Model {
  String get id;
  String get type;
  String serialize();
}
