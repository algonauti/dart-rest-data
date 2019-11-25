import 'package:equatable/equatable.dart';

import '../interfaces.dart';
import '../serializers/json_api.dart';

class JsonApiModel with EquatableMixinBase, EquatableMixin implements Model {
  JsonApiDocument jsonApiDoc;

  JsonApiModel(this.jsonApiDoc);

  JsonApiModel.create(
    String type, {
    Map<String, dynamic> attributes,
    Map<String, dynamic> relationships,
  }) : jsonApiDoc = JsonApiDocument.create(
          type,
          attributes ?? Map<String, dynamic>(),
          relationships ?? Map<String, dynamic>(),
        );

  JsonApiModel.init(String type) : this.create(type);

  JsonApiModel.from(JsonApiModel other)
      : this(JsonApiDocument.from(other.jsonApiDoc));

  JsonApiModel.shallowCopy(JsonApiModel other) : this(other.jsonApiDoc);

  Map<String, dynamic> get attributes => jsonApiDoc.attributes;
  Map<String, dynamic> get relationships => jsonApiDoc.relationships;
  Iterable<dynamic> get included => jsonApiDoc.included;
  Iterable<dynamic> get errors => jsonApiDoc.errors;
  set errors(Iterable<dynamic> value) => jsonApiDoc.errors = value;

  @override
  String get id => jsonApiDoc.id;

  @override
  String get type => jsonApiDoc.type;

  bool get isNew => jsonApiDoc.isNew;

  bool get hasErrors => errors != null ? errors.isNotEmpty : false;

  @override
  String serialize() => JsonApiSerializer().serialize(jsonApiDoc);

  String idFor(String relationshipName) => jsonApiDoc.idFor(relationshipName);
  String typeFor(String relationshipName) =>
      jsonApiDoc.typeFor(relationshipName);

  Iterable<String> idsFor(String relationshipName) =>
      jsonApiDoc.idsFor(relationshipName);

  Iterable<JsonApiDocument> includedDocs(String type, [Iterable<String> ids]) =>
      jsonApiDoc.includedDocs(type, ids);

  bool attributeHasErrors(String attributeName) => hasErrors
      ? errors.any((error) =>
          _isAttributeError(error, attributeName) && _hasErrorDetail(error))
      : false;

  Iterable<String> errorsFor(String attributeName) => errors
      .where((error) => _isAttributeError(error, attributeName))
      .map((error) => error['detail']);

  void clearErrorsFor(String attributeName) {
    errors = errors
        .where((error) => !_isAttributeError(error, attributeName))
        .toList();
  }

  void clearErrors() {
    jsonApiDoc.errors = null;
  }

  bool _isAttributeError(Map<String, dynamic> error, String attributeName) =>
      error['source']['pointer'] == "/data/attributes/$attributeName";

  bool _hasErrorDetail(Map<String, dynamic> error) =>
      error['detail'] != null &&
      error['detail'] is String &&
      (error['detail'] as String).isNotEmpty;

  void setHasOne(String relationshipName, JsonApiModel model) {
    if (relationships.containsKey(relationshipName)) {
      relationships[relationshipName]['data']['id'] = model.id;
    } else
      relationships[relationshipName] = {
        'data': {'id': model.id, 'type': model.type}
      };
  }

  static DateTime toDateTime(String value) =>
      (value == null || value.isEmpty) ? null : DateTime.parse(value).toLocal();

  static String toUtcIsoString(DateTime value) =>
      value.toUtc().toIso8601String();
}

abstract class JsonApiManyModel<T extends JsonApiModel> extends Iterable<T> {
  JsonApiManyDocument manyDoc;
  Iterable<T> models;

  JsonApiManyModel(this.manyDoc);

  @override
  Iterator<T> get iterator => models.iterator;

  int get currentPage => manyDoc.meta['current_page'];
  int get pageSize => manyDoc.meta['page_size'];
  int get totalPages => manyDoc.meta['total_pages'];
  int get totalCount => manyDoc.meta['total_count'];

  Iterable<JsonApiDocument> includedDocs(String type) =>
      manyDoc.includedDocs(type);
}
