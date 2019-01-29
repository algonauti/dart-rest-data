import 'package:cinderblock/data_store.dart';
import 'package:cinderblock/models/named_colored.dart';

class Tag extends NamedColored {
  Tag(jsonApiDoc) : super(jsonApiDoc);

  Tag.create(Map<String, dynamic> attributes,
      [Map<String, dynamic> relationships])
      : super.create(endpoint, attributes, relationships);

  static final String endpoint = 'tags';

  static Future<Tag> find(String id) async {
    return Tag(await DataStore().adapter.find(endpoint, id));
  }

  // Attributes

  String get family => attributes['family'];
  set family(String value) => attributes['family'] = value;

  // Instance Methods

  Future<Tag> save() async {
    return Tag(await DataStore().adapter.save(endpoint, jsonApiDoc));
  }
}
