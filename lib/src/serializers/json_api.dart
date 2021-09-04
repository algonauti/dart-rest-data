import 'dart:convert';

import '../exceptions.dart';
import '../interfaces.dart';

class JsonApiSerializer implements Serializer {
  @override
  JsonApiDocument deserialize(String payload) {
    try {
      Map<String, dynamic> parsed = parse(payload);
      var data = parsed['data'] ?? {};
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
  String serialize(Object document, {bool withIncluded = false}) {
    try {
      JsonApiDocument jsonApiDoc = (document as JsonApiDocument);
      Map<String, dynamic> jsonMap = {
        'data': {
          'id': jsonApiDoc.id,
          'type': jsonApiDoc.type,
          'attributes': jsonApiDoc.attributes,
          'relationships': jsonApiDoc.relationships,
        },
      };
      if (withIncluded) {
        jsonMap['included'] = jsonApiDoc.included;
      }
      return json.encode(jsonMap);
    } on TypeError {
      throw ArgumentError('document must be a JsonApiDocument');
    } on JsonUnsupportedObjectError {
      throw SerializationException();
    }
  }

  dynamic parse(String raw) => json.decode(raw);
}

class JsonApiDocument {
  String? id;
  String type;
  Map<String, dynamic> attributes;
  Map<String, dynamic> relationships;
  Iterable<dynamic> included;
  List<dynamic> errors;

  JsonApiDocument(
      this.id, this.type, this.attributes, Map<String, dynamic>? relationships,
      [Iterable<dynamic>? included = null])
      : errors = [],
        this.relationships = relationships ?? {},
        this.included = included ?? [];

  JsonApiDocument.create(this.type, this.attributes,
      [Map<String, dynamic>? relationships = null])
      : errors = [],
        included = [],
        this.relationships = relationships ?? {};

  JsonApiDocument.from(JsonApiDocument other)
      : this(
          other.id,
          other.type,
          Map<String, dynamic>.from(other.attributes),
          _deepCopyRelationships(other.relationships),
          List.from(other.included),
        );

  static _deepCopyRelationships(other) {
    var firstValue;
    if (other is Map) {
      if (other.isEmpty) {
        return Map<String, dynamic>();
      }
      firstValue = other.values.first;
      if (firstValue is! Map && firstValue is! List) {
        return Map<String, dynamic>.from(other);
      } else {
        return Map<String, dynamic>.fromIterables(
          other.keys as Iterable<String>,
          other.values.map((val) => _deepCopyRelationships(val)),
        );
      }
    }
    if (other is List) {
      if (other.isEmpty) {
        return <Map<String, dynamic>>[];
      }
      firstValue = other.first;
      if (firstValue is! Map && firstValue is! List) {
        return List<Map<String, dynamic>>.from(other);
      } else {
        return List<Map<String, dynamic>>.from(
            other.map((val) => _deepCopyRelationships(val)));
      }
    }
  }

  String get endpoint => type.replaceAll(RegExp('_'), '-');

  bool get isNew => id == null;

  bool get hasErrors => errors.isNotEmpty;

  Map<String, dynamic> dataForHasOne(String relationshipName) =>
      relationships.containsKey(relationshipName)
          ? (relationships[relationshipName]['data'] ?? Map<String, dynamic>())
          : Map<String, dynamic>();

  String? idFor(String relationshipName) =>
      dataForHasOne(relationshipName)['id'];

  String? typeFor(String relationshipName) =>
      dataForHasOne(relationshipName)['type'];

  Iterable<dynamic> dataForHasMany(String relationshipName) =>
      relationships[relationshipName]['data'] ?? [];

  Iterable<String?> idsFor(String relationshipName) =>
      relationships.containsKey(relationshipName)
          ? dataForHasMany(relationshipName).map((record) => record['id'])
          : <String>[];

  void setHasOne(String relationshipName, String? modelId, String? modelType) {
    Map<String, dynamic> relationshipMap = {'id': modelId, 'type': modelType};
    if (relationships.containsKey(relationshipName)) {
      if (relationships[relationshipName]['data'] == null) {
        relationships[relationshipName]['data'] = relationshipMap;
      } else {
        relationships[relationshipName]['data']['id'] = modelId;
      }
    } else {
      relationships[relationshipName] = {'data': relationshipMap};
    }
  }

  void clearHasOne(String relationshipName) {
    if (relationships.containsKey(relationshipName)) {
      relationships[relationshipName]['data'] = null;
    } else {
      relationships[relationshipName] = {'data': null};
    }
  }

  Iterable<JsonApiDocument> includedDocs(String type,
      [Iterable<String?>? ids]) {
    ids ??= idsFor(type);
    return included
        .where(
            (record) => record['type'] == type && ids!.contains(record['id']))
        .map<JsonApiDocument>((record) => JsonApiDocument(record['id'],
            record['type'], record['attributes'], record['relationships']));
  }

  bool attributeHasErrors(String attributeName) => hasErrors
      ? errors.any((error) =>
          _isAttributeError(error, attributeName) && _hasErrorDetail(error))
      : false;

  Iterable<String?> errorsFor(String attributeName) => errors
      .where((error) => _isAttributeError(error, attributeName))
      .map((error) => error['detail']);

  void clearErrorsFor(String attributeName) {
    errors = errors
        .where((error) => !_isAttributeError(error, attributeName))
        .toList();
  }

  void clearErrors() {
    errors = [];
  }

  void addErrorFor(String attributeName, String errorMessage) {
    errors.add({
      'source': {'pointer': "/data/attributes/$attributeName"},
      'detail': errorMessage,
    });
  }

  bool _isAttributeError(Map<String, dynamic> error, String attributeName) =>
      error['source']['pointer'] == "/data/attributes/$attributeName";

  bool _hasErrorDetail(Map<String, dynamic> error) =>
      error['detail'] != null &&
      error['detail'] is String &&
      (error['detail'] as String).isNotEmpty;
}

typedef FilterFunction = bool Function(JsonApiDocument?);

class JsonApiManyDocument extends Iterable<JsonApiDocument> {
  Iterable<JsonApiDocument> docs;
  Iterable<dynamic>? included;
  Map<String, dynamic>? meta;

  JsonApiManyDocument(this.docs, [this.included, this.meta]) {
    meta ??= Map<String, dynamic>();
    included ??= [];
  }

  @override
  Iterator<JsonApiDocument> get iterator => docs.iterator;

  void append(Iterable<JsonApiDocument> moreDocs) {
    docs = docs.followedBy(moreDocs);
  }

  void filter(FilterFunction filterFn) {
    docs = docs.where(filterFn);
  }

  Iterable<String?> idsForHasOne(String relationshipName) => docs
      .map((doc) => doc.idFor(relationshipName))
      .where((id) => id != null)
      .toSet();

  Iterable<String?> idsForHasMany(String relationshipName) => docs
      .map((doc) => doc.idsFor(relationshipName))
      .expand((ids) => ids)
      .where((id) => id != null)
      .toSet();

  Iterable<JsonApiDocument> includedDocs(String type) => included!
      .where((record) => record['type'] == type)
      .map((record) => JsonApiDocument(record['id'], record['type'],
          record['attributes'], record['relationships']));
}
