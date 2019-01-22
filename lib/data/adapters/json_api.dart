import 'package:cinderblock/data/adapters/mixins/http.dart';
import 'package:cinderblock/data/interfaces.dart';
import 'package:cinderblock/data/serializers/json_api.dart';

class JsonApiAdapter extends Adapter with Http {
  String apiPath;

  JsonApiAdapter(hostname, this.apiPath) : super(JsonApiSerializer()) {
    this.hostname = hostname;
  }

  @override
  Future<JsonApiDocument> find(String endpoint, String id) async {
    final response = await httpGet(path: "$apiPath/$endpoint/$id");
    String payload = checkAndDecode(response);
    return serializer.deserializeOne(payload);
  }

  @override
  Future<Iterable<JsonApiDocument>> findMany(
      String endpoint, Iterable<String> ids) async {
    return await query(endpoint, {'filter[id]': ids.join(',')});
  }

  @override
  Future<Iterable<JsonApiDocument>> findAll(String endpoint) async {
    final response = await httpGet(path: "$apiPath/$endpoint");
    String payload = checkAndDecode(response);
    return serializer.deserializeMany(payload);
  }

  @override
  Future<Iterable<JsonApiDocument>> query(
      String endpoint, Map<String, String> params) async {
    final response =
        await httpGet(path: "$apiPath/$endpoint", queryParams: params);
    String payload = checkAndDecode(response);
    return serializer.deserializeMany(payload);
  }

  @override
  Future<JsonApiDocument> save(String endpoint, dynamic document) {
    if (document is JsonApiDocument) {
      // TODO: implement save
      return null;
    } else {
      throw ArgumentError('document must be a JsonApiDocument');
    }
  }

  @override
  Future delete(String endpoint, dynamic document) {
    if (document is JsonApiDocument) {
      // TODO: implement delete
      return null;
    } else {
      throw ArgumentError('document must be a JsonApiDocument');
    }
  }
}
