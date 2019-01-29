import 'package:cinderblock/app_model.dart';
import 'package:cinderblock/data_store.dart';
import 'package:cinderblock/models/company.dart';

class User extends AppModel {
  User(jsonApiDoc) : super(jsonApiDoc);

  User.create(Map<String, dynamic> attributes,
      [Map<String, dynamic> relationships])
      : super.create(endpoint, attributes, relationships);

  static final String endpoint = 'users';

  static Future<User> find(String id) async {
    return User(await DataStore().adapter.find(endpoint, id));
  }

  static Future<Iterable<User>> findAll() async {
    return (await DataStore().adapter.findAll(endpoint))
        .map((jsonApiDoc) => User(jsonApiDoc));
  }

  // TODO query() class method

  // Attributes

  String get email => attributes['email'];
  set email(String value) => attributes['email'] = value;

  String get firstName => attributes['first_name'];
  set firstName(String value) => attributes['first_name'] = value;

  String get lastName => attributes['last_name'];
  set lastName(String value) => attributes['last_name'] = value;

  String get phoneNumber => attributes['phone'];
  set phoneNumber(String value) => attributes['phone'] = value;

  String get avatarUrl => attributes['avatar_url'];

  // Has-One Relationships

  Future<Company> get company async => await Company.find(idFor('company'));

  // Instance Methods

  Future<User> save() async {
    return User(await DataStore().adapter.save(endpoint, jsonApiDoc));
  }

  Future<User> reload() async {
    return find(id);
  }
}
