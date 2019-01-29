import 'package:cinderblock/data_store.dart';
import 'package:cinderblock/models/named_colored.dart';

class JobStatus extends NamedColored {
  JobStatus(jsonApiDoc) : super(jsonApiDoc);

  JobStatus.create(Map<String, dynamic> attributes,
      [Map<String, dynamic> relationships])
      : super.create('job_statuses', attributes, relationships);

  static final String endpoint = 'job-statuses';

  static Future<JobStatus> find(String id) async {
    return JobStatus(await DataStore().adapter.find(endpoint, id));
  }

  // Attributes

  bool get closeJob => attributes['close_job'];
  set closeJob(bool value) => attributes['close_job'] = value;

  // Instance Methods

  Future<JobStatus> save() async {
    return JobStatus(await DataStore().adapter.save(endpoint, jsonApiDoc));
  }
}
