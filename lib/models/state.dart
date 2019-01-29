import 'package:cinderblock/app_model.dart';
import 'package:cinderblock/data_store.dart';

class State extends AppModel {
  State(jsonApiDoc) : super(jsonApiDoc);

  static final String endpoint = 'states';

  static Future<State> find(String id) async {
    return State(await DataStore().adapter.find(endpoint, id));
  }

  static Future<Iterable<State>> findMany(Iterable<String> ids) async {
    return (await DataStore().adapter.findMany(endpoint, ids))
        .map((jsonApiDoc) => State(jsonApiDoc));
  }

  // Attributes

  String get code => attributes['code'];
  String get name => attributes['name'];
}
