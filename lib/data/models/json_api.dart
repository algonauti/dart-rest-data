import 'package:cinderblock/data/interfaces.dart';
import 'package:cinderblock/data/serializers/json_api.dart';

class JsonApiModel implements Model {
  JsonApiDocument jsonApiDocument;

  JsonApiModel(this.jsonApiDocument);

  Map<String, dynamic> get attributes => jsonApiDocument.attributes;
  Map<String, dynamic> get relationships => jsonApiDocument.relationships;
  Iterable<dynamic> get included => jsonApiDocument.included;

  @override
  String get id => attributes['id'];

  @override
  String serialize() {
    return JsonApiSerializer().serialize(jsonApiDocument);
  }

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

  Iterable<JsonApiDocument> includedDocs(String type) {
    return included.where((record) => record['type'] == type).map((record) =>
        JsonApiDocument(record['attributes'], record['relationships']));
  }
}
