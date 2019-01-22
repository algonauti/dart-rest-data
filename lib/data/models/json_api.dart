import 'package:cinderblock/data/interfaces.dart';
import 'package:cinderblock/data/serializers/json_api.dart';

class JsonApiModel implements Model {
  JsonApiDocument jsonApiDocument;

  JsonApiModel(this.jsonApiDocument);

  Map<String, dynamic> get attributes => jsonApiDocument.attributes;
  Map<String, dynamic> get relationships => jsonApiDocument.relationships;

  @override
  String get id => attributes['id'];

  String idFor(String relationshipName) {
    if (relationships.containsKey(relationshipName)) {
      Map<String, dynamic> data = relationships[relationshipName]['data'];
      return data['id'];
    } else
      return null;
  }
}
