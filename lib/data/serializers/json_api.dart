import 'dart:convert';

import 'package:cinderblock/data/interfaces.dart';

class JsonApiSerializer implements Serializer {
  @override
  JsonApiDocument deserialize(String payload) {
    Map<String, dynamic> parsed = parse(payload);
    var data = parsed['data'];
    return JsonApiDocument(data['id'], data['type'], data['attributes'],
        data['relationships'], parsed['included']);
  }

  @override
  Iterable<JsonApiDocument> deserializeMany(String payload) {
    Map<String, dynamic> parsed = parse(payload);
    return (parsed['data'] as Iterable).map((item) => JsonApiDocument(
        item['id'], item['type'], item['attributes'], item['relationships']));
  }

  @override
  String serialize(dynamic document) {
    if (document is! JsonApiDocument) {
      throw ArgumentError('document must be a JsonApiDocument');
    }
    return json.encode({
      'data': {
        'id': document.id,
        'type': document.type,
        'attributes': document.attributes,
        'relationships': document.relationships
      }
    });
  }

  dynamic parse(String raw) {
    return json.decode(raw);
  }
}

class JsonApiDocument {
  String id;
  String type;
  Map<String, dynamic> attributes;
  Map<String, dynamic> relationships;
  Iterable<dynamic> included;
  Iterable<dynamic> errors;

  JsonApiDocument(this.id, this.type, this.attributes, this.relationships,
      [this.included]);

  JsonApiDocument.create(this.type, this.attributes, [this.relationships]);

  bool get isNew => id == null;
}
