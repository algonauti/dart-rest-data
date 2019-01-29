import 'package:cinderblock/data_store.dart';
import 'package:cinderblock/models/named_colored.dart';

class AppointmentType extends NamedColored {
  AppointmentType(jsonApiDoc) : super(jsonApiDoc);

  AppointmentType.create(Map<String, dynamic> attributes,
      [Map<String, dynamic> relationships])
      : super.create('appointment_types', attributes, relationships);

  static final String endpoint = 'appointment-types';

  static Future<AppointmentType> find(String id) async {
    return AppointmentType(await DataStore().adapter.find(endpoint, id));
  }

  // Instance Methods

  Future<AppointmentType> save() async {
    return AppointmentType(
        await DataStore().adapter.save(endpoint, jsonApiDoc));
  }
}
