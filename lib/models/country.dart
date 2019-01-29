import 'package:cinderblock/app_model.dart';
import 'package:cinderblock/data_store.dart';
import 'package:cinderblock/models/state.dart';

class Country extends AppModel {
  Country(jsonApiDoc) : super(jsonApiDoc);

  static final String endpoint = 'countries';

  static Future<Country> find(String id) async {
    return Country(await DataStore().adapter.find(endpoint, id));
  }

  static Future<Iterable<Country>> findAll() async {
    return (await DataStore().adapter.findAll(endpoint))
        .map((jsonApiDoc) => Country(jsonApiDoc));
  }

  // Attributes

  String get name => attributes['name'];

  // Has-Many Relationships

  Future<Iterable<State>> get states async {
    return (await State.findMany(idsFor('states')));
  }
}
