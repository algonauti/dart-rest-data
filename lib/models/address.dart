import 'package:cinderblock/app_model.dart';
import 'package:cinderblock/data_store.dart';
import 'package:cinderblock/models/country.dart';
import 'package:cinderblock/models/state.dart';

class Address extends AppModel {
  Address(jsonApiDoc) : super(jsonApiDoc);

  Address.create(Map<String, dynamic> attributes,
      [Map<String, dynamic> relationships])
      : super.create(endpoint, attributes, relationships);

  static final String endpoint = 'addresses';

  static Future<Address> find(String id) async {
    return Address(await DataStore().adapter.find(endpoint, id));
  }

  // Attributes

  String get zip => attributes['zip'];
  set zip(String value) => attributes['zip'] = value;

  String get city => attributes['city'];
  set city(String value) => attributes['city'] = value;

  String get street1 => attributes['street1'];
  set street1(String value) => attributes['street1'] = value;

  String get street2 => attributes['street2'];
  set street2(String value) => attributes['street2'] = value;

  bool get isPrimary => attributes['is_primary'];
  set isPrimary(bool value) => attributes['is_primary'] = value;

  double get latitude => attributes['latitude'];
  set latitude(double value) => attributes['latitude'] = value;

  double get longitude => attributes['longitude'];
  set longitude(double value) => attributes['longitude'] = value;

  String get geocodingPrecision => attributes['geocoding_precision'];
  set geocodingPrecision(String value) =>
      attributes['geocoding_precision'] = value;

  String get timezone => attributes['timezone'];

  // Has-One Relationships

  Future<Country> get country async => await Country.find(idFor('country'));
  void setCountry(Country model) => setHasOne('country', model);

  Future<State> get state async => await State.find(idFor('state'));
  void setState(State model) => setHasOne('state', model);

  // Instance Methods

  Future<Address> save() async {
    return Address(await DataStore().adapter.save(endpoint, jsonApiDoc));
  }
}
