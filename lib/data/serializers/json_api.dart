import 'dart:convert';

import 'package:cinderblock/data/exceptions.dart';
import 'package:cinderblock/data/interfaces.dart';

class JsonApiSerializer implements Serializer {
  @override
  JsonApiDocument deserialize(String payload) {
    try {
      Map<String, dynamic> parsed = parse(payload);
      var data = parsed['data'];
      return JsonApiDocument(data['id'], data['type'], data['attributes'],
          data['relationships'], parsed['included']);
    } on FormatException {
      throw DeserializationException();
    }
  }

  @override
  JsonApiManyDocument deserializeMany(String payload) {
    Map<String, dynamic> parsed = parse(payload);
    var docs = (parsed['data'] as Iterable).map((item) => JsonApiDocument(
        item['id'],
        item['type'],
        item['attributes'],
        item['relationships'],
        parsed['included']));
    return JsonApiManyDocument(docs, parsed['included'], parsed['meta']);
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
        //TODO included
      });
    } on CastError {
      throw ArgumentError('document must be a JsonApiDocument');
    } on JsonUnsupportedObjectError {
      throw SerializationException();
    }
  }

  dynamic parse(String raw) => json.decode(raw);
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

  JsonApiDocument.from(JsonApiDocument other)
      : this(
          other.id,
          other.type,
          Map<String, dynamic>.from(other.attributes),
          other.relationships != null
              ? _deepCopyRelationships(other.relationships)
              : null,
          other.included != null ? List.from(other.included) : null,
        );

  bool get isNew => id == null;

  Map<String, dynamic> dataForHasOne(String relationshipName) =>
      relationships.containsKey(relationshipName)
          ? (relationships[relationshipName]['data'] ?? Map<String, dynamic>())
          : Map<String, dynamic>();

  String idFor(String relationshipName) =>
      dataForHasOne(relationshipName)['id'];

  String typeFor(String relationshipName) =>
      dataForHasOne(relationshipName)['type'];

  Iterable<dynamic> dataForHasMany(String relationshipName) =>
      relationships[relationshipName]['data'] ?? List();

  Iterable<String> idsFor(String relationshipName) =>
      relationships.containsKey(relationshipName)
          ? dataForHasMany(relationshipName).map((record) => record['id'])
          : List<String>();

  Iterable<JsonApiDocument> includedDocs(String type, [Iterable<String> ids]) {
    ids ??= idsFor(type);
    return (included ?? List())
        .where((record) => record['type'] == type && ids.contains(record['id']))
        .map<JsonApiDocument>((record) => JsonApiDocument(record['id'],
            record['type'], record['attributes'], record['relationships']));
  }
}

class JsonApiManyDocument extends Iterable<JsonApiDocument> {
  Iterable<JsonApiDocument> docs;
  Iterable<dynamic> included;
  Map<String, dynamic> meta;

  JsonApiManyDocument(this.docs, [this.included, this.meta]) {
    meta ??= Map<String, dynamic>();
  }

  @override
  Iterator<JsonApiDocument> get iterator => docs.iterator;

  void append(Iterable<JsonApiDocument> moreDocs) {
    docs = docs.followedBy(moreDocs);
  }

  Iterable<String> idsForHasOne(String relationshipName) =>
      docs.map((doc) => doc.idFor(relationshipName)).toSet();

  Iterable<String> idsForHasMany(String relationshipName) => docs
      .map((doc) => doc.idsFor(relationshipName))
      .expand((ids) => ids)
      .toSet();

  Iterable<JsonApiDocument> includedDocs(String type) => included
      .where((record) => record['type'] == type)
      .map((record) => JsonApiDocument(record['id'], record['type'],
          record['attributes'], record['relationships']));
}

_deepCopyRelationships(other) {
  var firstValue;
  if (other is Map) {
    if (other.isEmpty) return Map<String, dynamic>();
    firstValue = other.values.first;
    if (firstValue is! Map && firstValue is! List)
      return Map<String, dynamic>.from(other);
    else
      return Map<String, dynamic>.fromIterables(
        other.keys,
        other.values.map((val) => _deepCopyRelationships(val)),
      );
  }
  if (other is List) {
    if (other.isEmpty) return List<Map<String, dynamic>>();
    firstValue = other.first;
    if (firstValue is! Map && firstValue is! List)
      return List<Map<String, dynamic>>.from(other);
    else
      return List<Map<String, dynamic>>.from(
          other.map((val) => _deepCopyRelationships(val)));
  }
}
