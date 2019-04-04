import 'package:cinderblock/data/interfaces.dart';
import 'package:cinderblock/data/serializers/json_api.dart';
import 'package:equatable/equatable.dart';

class JsonApiModel with EquatableMixinBase, EquatableMixin implements Model {
  JsonApiDocument jsonApiDoc;

  JsonApiModel(this.jsonApiDoc);

  JsonApiModel.create(String type, Map<String, dynamic> attributes,
      [Map<String, dynamic> relationships]) {
    jsonApiDoc = JsonApiDocument.create(type, attributes, relationships);
  }

  Map<String, dynamic> get attributes => jsonApiDoc.attributes;
  Map<String, dynamic> get relationships => jsonApiDoc.relationships;
  Iterable<dynamic> get included => jsonApiDoc.included;
  Iterable<dynamic> get errors => jsonApiDoc.errors;

  @override
  String get id => jsonApiDoc.id;

  @override
  String get type => jsonApiDoc.type;

  bool get isNew => jsonApiDoc.isNew;

  bool get hasErrors => errors.isNotEmpty;

  @override
  String serialize() => JsonApiSerializer().serialize(jsonApiDoc);

  String idFor(String relationshipName) => jsonApiDoc.idFor(relationshipName);
  String typeFor(String relationshipName) =>
      jsonApiDoc.typeFor(relationshipName);

  Iterable<String> idsFor(String relationshipName) =>
      jsonApiDoc.idsFor(relationshipName);

  Iterable<JsonApiDocument> includedDocs(String type, [Iterable<String> ids]) =>
      jsonApiDoc.includedDocs(type, ids);

  Iterable<String> errorsFor(String attributeName) {
    return errors
        .where((error) =>
            error['source']['pointer'] == "/data/attributes/$attributeName")
        .map((error) => error['detail']);
  }

  void setHasOne(String relationshipName, JsonApiModel model) {
    if (relationships.containsKey(relationshipName)) {
      relationships[relationshipName]['data']['id'] = model.id;
    } else
      relationships[relationshipName] = {
        'data': {'id': model.id, 'type': model.type}
      };
  }

  static DateTime toDateTime(String value) => DateTime.parse(value);
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
