import 'package:equatable/equatable.dart';

import '../interfaces.dart';
import '../serializers/json_api.dart';

class JsonApiModel with EquatableMixin implements Model {
  JsonApiDocument jsonApiDoc;

  JsonApiModel(this.jsonApiDoc);

  JsonApiModel.create(
    String type, {
    Map<String, dynamic>? attributes,
    Map<String, dynamic>? relationships,
  }) : jsonApiDoc = JsonApiDocument.create(
          type,
          attributes ?? Map<String, dynamic>(),
          relationships ?? Map<String, dynamic>(),
        );

  JsonApiModel.init(String type) : this.create(type);

  JsonApiModel.from(JsonApiModel other)
      : this(JsonApiDocument.from(other.jsonApiDoc));

  JsonApiModel.shallowCopy(JsonApiModel other) : this(other.jsonApiDoc);

  String get endpoint => jsonApiDoc.endpoint;
  Map<String, dynamic> get attributes => jsonApiDoc.attributes;
  Map<String, dynamic> get relationships => jsonApiDoc.relationships;
  Iterable<dynamic> get included => jsonApiDoc.included;
  List<dynamic> get errors => jsonApiDoc.errors;

  @override
  String? get id => jsonApiDoc.id;

  @override
  String? get type => jsonApiDoc.type;

  bool get isNew => jsonApiDoc.isNew;

  bool get hasErrors => jsonApiDoc.hasErrors;

  @override
  String serialize() => JsonApiSerializer().serialize(jsonApiDoc);

  String? idFor(String relationshipName) => jsonApiDoc.idFor(relationshipName);
  String? typeFor(String relationshipName) =>
      jsonApiDoc.typeFor(relationshipName);

  Iterable<String> idsFor(String relationshipName) =>
      jsonApiDoc.idsFor(relationshipName);

  Iterable<JsonApiDocument> includedDocs(String type,
          [Iterable<String>? ids]) =>
      jsonApiDoc.includedDocs(type, ids);

  bool attributeHasErrors(String attributeName) =>
      jsonApiDoc.attributeHasErrors(attributeName);

  Iterable<String> errorsFor(String attributeName) =>
      jsonApiDoc.errorsFor(attributeName);

  void clearErrorsFor(String attributeName) {
    jsonApiDoc.clearErrorsFor(attributeName);
  }

  void clearErrors() {
    jsonApiDoc.clearErrors();
  }

  void addErrorFor(String attributeName, String errorMessage) {
    jsonApiDoc.addErrorFor(attributeName, errorMessage);
  }

  void setHasOne(String relationshipName, JsonApiModel model) {
    jsonApiDoc.setHasOne(relationshipName, model.id, model.type);
  }

  void clearHasOne(String relationshipName) {
    jsonApiDoc.clearHasOne(relationshipName);
  }

  static DateTime? toDateTime(String value) =>
      (value.isEmpty) ? null : DateTime.parse(value).toLocal();

  static String toUtcIsoString(DateTime value) =>
      value.toUtc().toIso8601String();

  @override
  List<Object?> get props => [id, type, errors];
}

abstract class JsonApiManyModel<T extends JsonApiModel> extends Iterable<T> {
  JsonApiManyDocument manyDoc;
  late Iterable<T> models;

  JsonApiManyModel(this.manyDoc);

  @override
  Iterator<T> get iterator => models.iterator;

  bool get hasMeta => manyDoc.meta.isNotEmpty;
  int? get currentPage => manyDoc.meta['current_page'];
  int? get pageSize => manyDoc.meta['page_size'];
  int? get totalPages => manyDoc.meta['total_pages'];
  int? get totalCount => manyDoc.meta['total_count'];

  Iterable<JsonApiDocument> includedDocs(String type) =>
      manyDoc.includedDocs(type);
}
