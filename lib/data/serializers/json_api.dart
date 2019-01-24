import 'dart:convert';

import 'package:cinderblock/data/interfaces.dart';

class JsonApiSerializer implements Serializer {
  @override
  JsonApiDocument deserializeOne(String payload) {
    Map<String, dynamic> parsed = json.decode(payload);
    var data = parsed['data'];
    if (parsed.containsKey('included'))
      return JsonApiDocument(data['id'], data['type'], data['attributes'],
          data['relationships'], parsed['included']);
    else
      return JsonApiDocument(
          data['id'], data['type'], data['attributes'], data['relationships']);
  }

  @override
  Iterable<JsonApiDocument> deserializeMany(String payload) {
    Map<String, dynamic> parsed = json.decode(payload);
    return (parsed['data'] as Iterable).map((item) => JsonApiDocument(
        item['id'], item['type'], item['attributes'], item['relationships']));
  }

  @override
  String serialize(dynamic document) {
    if (document is JsonApiDocument) {
      return json.encode({
        'data': {
          'attributes': document.attributes,
          'relationships': document.relationships
        }
      });
    } else {
      throw ArgumentError('document must be a JsonApiDocument');
    }
  }
}

class JsonApiDocument {
  String id;
  String type;
  Map<String, dynamic> attributes;
  Map<String, dynamic> relationships;
  Iterable<dynamic> included;

  JsonApiDocument(this.id, this.type, this.attributes, this.relationships,
      [this.included]);

  bool get isNew => id == null;
}
