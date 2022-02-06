import 'dart:convert';

import 'package:collection/collection.dart';

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
    var docs = List<JsonApiDocument>.from(
      List.from(parsed['data']).map(
        (item) => JsonApiDocument(
          item['id'],
          item['type'],
          item['attributes'],
          item['relationships'],
          List.from(parsed['included'] ?? []),
        ),
      ),
    );
    return JsonApiManyDocument(
      docs,
      List.from(parsed['included'] ?? []),
      parsed['meta'],
    );
  }

  @override
  String serialize(Object document, {bool withIncluded = false}) {
    try {
      JsonApiDocument jsonApiDoc = (document as JsonApiDocument);
      Map<String, dynamic> jsonMap = {
        'data': {
          'type': jsonApiDoc.type,
          'attributes': jsonApiDoc.attributes,
          'relationships': jsonApiDoc.relationships,
        },
      };
      if (withIncluded) {
        jsonMap['included'] = jsonApiDoc.included;
      }
      if (jsonApiDoc.id != null) {
        jsonMap['data']['id'] = jsonApiDoc.id;
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
  String? type;
  Map<String, dynamic> attributes;
  Map<String, dynamic> relationships;
  List<dynamic> included;
  List<dynamic> errors;
  _Cache<List<String>> _stringsCache = _Cache<List<String>>();

  JsonApiDocument(
      this.id, this.type, this.attributes, Map<String, dynamic>? relationships,
      [List<dynamic>? included = null])
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
          other.included,
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

  String get endpoint => (type ?? '').replaceAll(RegExp('_'), '-');

  bool get isNew => id == null;

  T getAttribute<T>(String key) {
    final rawAttribute = attributes[key];

    switch (T.toString()) {
      case 'bool':
        return rawAttribute ?? false;
      case 'String':
        return rawAttribute ?? '';
      case 'int':
        return rawAttribute ?? 0;
      case 'double':
        return rawAttribute ?? 0.0;
      case 'List<bool>':
        return rawAttribute == null
            ? List<bool>.empty() as T
            : (rawAttribute as List).cast<bool>() as T;
      case 'List<String>':
        return rawAttribute == null
            ? List<String>.empty() as T
            : (rawAttribute as List).cast<String>() as T;
      case 'List<int>':
        return rawAttribute == null
            ? List<int>.empty() as T
            : (rawAttribute as List).cast<int>() as T;
      case 'List<double>':
        return rawAttribute == null
            ? List<double>.empty() as T
            : (rawAttribute as List).cast<double>() as T;
    }

    return rawAttribute;
  }

  void setAttribute<T>(String key, T value) {
    var rawValue;
    switch (T) {
      case String:
        rawValue = value == '' ? null : value;
        break;
      default:
        rawValue = value;
    }
    attributes[key] = rawValue;
  }

  bool get hasErrors => errors.isNotEmpty;

  Map<String, dynamic> dataForHasOne(String relationshipName) =>
      relationships.containsKey(relationshipName)
          ? (relationships[relationshipName]['data'] ?? Map<String, dynamic>())
          : Map<String, dynamic>();

  String? idFor(String relationshipName) =>
      dataForHasOne(relationshipName)['id'];

  String? typeFor(String relationshipName) =>
      dataForHasOne(relationshipName)['type'];

  List<dynamic> dataForHasMany(String relationshipName) =>
      relationships[relationshipName]['data'] ?? [];

  List<String> idsFor(String relationshipName) => _stringsCache.readOrLoad(
      key: 'idsFor:${relationshipName}',
      loader: () => _idsFor(relationshipName));

  List<String> _idsFor(String relationshipName) =>
      relationships.containsKey(relationshipName)
          ? List<String>.from(
              dataForHasMany(relationshipName).map((record) => record['id']))
          : <String>[];

  void setHasOne(String relationshipName, String modelId, String modelType) {
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

  List<JsonApiDocument> includedDocs(String type, [List<String>? ids]) {
    ids ??= idsFor(type);
    return List<JsonApiDocument>.from(included
        .where(
            (record) => record['type'] == type && ids!.contains(record['id']))
        .map<JsonApiDocument>((record) => JsonApiDocument(record['id'],
            record['type'], record['attributes'], record['relationships'])));
  }

  JsonApiDocument? includedDoc(String type) {
    var id = idFor(type);
    var it = included
        .where((record) => record['type'] == type && record['id'] == id)
        .map<JsonApiDocument>((record) => JsonApiDocument(record['id'],
            record['type'], record['attributes'], record['relationships']));

    return it.isNotEmpty ? it.first : null;
  }

  List<String> includedIdsFor(String relationshipName, String modelType) =>
      _stringsCache.readOrLoad(
          key: 'includedIdsFor:${relationshipName}',
          loader: () => _includedIdsFor(relationshipName, modelType));

  List<String> _includedIdsFor(String relationshipName, String modelType) =>
      List<String>.from(includedDocs(relationshipName)
          .map((jsonApiDoc) => jsonApiDoc.idFor(modelType))
          .whereNotNull()
          .toSet());

  bool attributeHasErrors(String attributeName) => hasErrors
      ? errors.any((error) =>
          _isAttributeError(error, attributeName) && _hasErrorDetail(error))
      : false;

  List<String> errorsFor(String attributeName) => List<String>.from(errors
      .where((error) => _isAttributeError(error, attributeName))
      .map((error) => error['detail']));

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

typedef FilterFunction = bool Function(JsonApiDocument);

class JsonApiManyDocument extends Iterable<JsonApiDocument> {
  List<JsonApiDocument> docs;
  List<dynamic> included;
  Map<String, dynamic> meta;
  _Cache<List<String>> _idsCache = _Cache<List<String>>();
  _Cache<List<JsonApiDocument>> _docsCache = _Cache<List<JsonApiDocument>>();

  JsonApiManyDocument(
    this.docs, [
    List<dynamic>? included,
    Map<String, dynamic>? meta,
  ])  : this.meta = meta ?? Map<String, dynamic>(),
        this.included = included ?? [];

  @override
  Iterator<JsonApiDocument> get iterator => docs.iterator;

  void append(List<JsonApiDocument> moreDocs) {
    docs = docs.followedBy(moreDocs).toList();
  }

  void filter(FilterFunction filterFn) {
    docs = docs.where(filterFn).toList();
  }

  List<String> idsForHasOne(String relationshipName) => _idsCache.readOrLoad(
        key: 'idsForHasOne:${relationshipName}',
        loader: () => _idsForHasOne(relationshipName),
      );

  List<String> _idsForHasOne(String relationshipName) => List<String>.from(docs
      .map((doc) => doc.idFor(relationshipName))
      .whereType<String>()
      .toSet());

  List<String> idsForHasMany(String relationshipName) => _idsCache.readOrLoad(
        key: 'idsForHasMany:${relationshipName}',
        loader: () => _idsForHasMany(relationshipName),
      );

  List<String> _idsForHasMany(String relationshipName) => List<String>.from(docs
      .map((doc) => doc.idsFor(relationshipName))
      .expand((ids) => ids)
      .toSet());

  List<JsonApiDocument> includedDocs(String type) => _docsCache.readOrLoad(
        key: 'includedDocs:${type}',
        loader: () => _includedDocs(type),
      );

  List<JsonApiDocument> _includedDocs(String type) =>
      List<JsonApiDocument>.from(included
          .where((record) => record['type'] == type)
          .map((record) => JsonApiDocument(record['id'], record['type'],
              record['attributes'], record['relationships'])));

  List<String> includedIdsFor(String relationshipName, String modelType) =>
      _idsCache.readOrLoad(
        key: 'includedIdsFor:${relationshipName}',
        loader: () => _includedIdsFor(relationshipName, modelType),
      );

  List<String> _includedIdsFor(String relationshipName, String modelType) =>
      List<String>.from(includedDocs(relationshipName)
          .map((jsonApiDoc) => jsonApiDoc.idFor(modelType))
          .whereNotNull()
          .toSet());
}

class _Cache<T> {
  Map<String, T> _map = Map<String, T>();

  T readOrLoad({
    required String key,
    required T Function() loader,
  }) =>
      _map[key] ?? _load(key, loader);

  T _load(String key, T Function() loader) {
    T value = loader();
    _map[key] = value;
    return value;
  }
}
