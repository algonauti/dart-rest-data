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
  String serialize(Object document) {
    try {
      JsonApiDocument jsonApiDoc = (document as JsonApiDocument);
      return json.encode({
        'data': {
          'id': jsonApiDoc.id,
          'type': jsonApiDoc.type,
          'attributes': jsonApiDoc.attributes,
          'relationships': jsonApiDoc.relationships
        }
      });
    } on CastError {
      throw ArgumentError('document must be a JsonApiDocument');
    }
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

  String idFor(String relationshipName) {
    if (relationships.containsKey(relationshipName)) {
      Map<String, dynamic> data = relationships[relationshipName]['data'];
      return data['id'];
    } else
      return null;
  }

  Iterable<String> idsFor(String relationshipName) {
    if (relationships.containsKey(relationshipName)) {
      Iterable<dynamic> data = relationships[relationshipName]['data'];
      return data.map((record) => record['id']);
    } else
      return List<String>();
  }

  Iterable<JsonApiDocument> includedDocs(String type, [Iterable<String> ids]) {
    ids ??= idsFor(type);
    return included
        .where((record) => record['type'] == type && ids.contains(record['id']))
        .map<JsonApiDocument>((record) => JsonApiDocument(record['id'],
            record['type'], record['attributes'], record['relationships']));
  }
}
