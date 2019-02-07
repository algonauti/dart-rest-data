abstract class Serializer {
  String serialize(dynamic document);
  dynamic deserialize(String payload);
  Iterable<dynamic> deserializeMany(String payload);
}

abstract class Adapter {
  Serializer serializer;

  Adapter(this.serializer);

  Future<dynamic> find(String endpoint, String id);
  Future<Iterable<dynamic>> findMany(String endpoint, List<String> ids);
  Future<Iterable<dynamic>> findAll(String endpoint);
  Future<Iterable<dynamic>> query(String endpoint, Map<String, String> params);
  Future<dynamic> save(String endpoint, dynamic document);
  Future delete(String endpoint, dynamic document);
}

abstract class Model {
  String get id;
  String get type;
  String serialize();
}
