import 'package:cinderblock/app_model.dart';
import 'package:cinderblock/data_store.dart';
import 'package:cinderblock/models/address.dart';
import 'package:cinderblock/models/appointment_type.dart';
import 'package:cinderblock/models/job_status.dart';
import 'package:cinderblock/models/tag.dart';
import 'package:cinderblock/models/user.dart';

class Company extends AppModel {
  Company(jsonApiDoc) : super(jsonApiDoc);

  static final String endpoint = 'companies';

  static Future<Company> find(String id) async {
    return Company(await DataStore().adapter.find(endpoint, id));
  }

  // Attributes

  String get name => attributes['name'];
  set name(String value) => attributes['name'] = value;

  String get website => attributes['website'];
  set website(String value) => attributes['website'] = value;

  String get email => attributes['email'];
  set email(String value) => attributes['email'] = value;

  String get contactPhone => attributes['contact_phone'];
  set contactPhone(String value) => attributes['contact_phone'] = value;

  String get contactName => attributes['contact_name'];
  set contactName(String value) => attributes['contact_name'] = value;

  String get contactFax => attributes['contact_fax'];
  set contactFax(String value) => attributes['contact_fax'] = value;

  // Has-One Relationships

  Future<User> get owner async => await User.find(idFor('owner'));

  // Has-One Included Relationships

  Address get address => Address(includedDocs('addresses').first);

  // Has-Many Included Relationships

  Iterable<AppointmentType> get appointmentTypes {
    return includedDocs('appointment_types')
        .map((jsonApiDoc) => AppointmentType(jsonApiDoc));
  }

  Iterable<JobStatus> get jobStatuses =>
      includedDocs('job_statuses').map((jsonApiDoc) => JobStatus(jsonApiDoc));

  Iterable<Tag> get tags =>
      includedDocs('tags').map((jsonApiDoc) => Tag(jsonApiDoc));

  // Instance Methods

  Future<Company> save() async {
    return Company(await DataStore().adapter.save(endpoint, jsonApiDoc));
  }

  Future<Company> reload() async {
    return find(id);
  }
}
