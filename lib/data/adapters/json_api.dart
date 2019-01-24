import 'package:cinderblock/data/adapters/mixins/http.dart';
import 'package:cinderblock/data/interfaces.dart';
import 'package:cinderblock/data/serializers/json_api.dart';

class JsonApiAdapter extends Adapter with Http {
  String apiPath;

  JsonApiAdapter(hostname, this.apiPath) : super(JsonApiSerializer()) {
    this.hostname = hostname;
    addHeader('Content-Type', 'application/json; charset=utf-8');
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
  Future<JsonApiDocument> save(String endpoint, dynamic document) async {
    if (document is JsonApiDocument) {
      var response;
      if (document.isNew) {
        response = await httpPost(
            path: "$apiPath/$endpoint", body: serializer.serialize(document));
      } else {
        response = await httpPatch(
            path: "$apiPath/$endpoint/${document.id}",
            body: serializer.serialize(document));
      }
      String payload = checkAndDecode(response);
      return serializer.deserializeOne(payload);
    } else {
      throw ArgumentError('document must be a JsonApiDocument');
    }
  }

  @override
  Future delete(String endpoint, dynamic document) async {
    if (document is JsonApiDocument) {
      // TODO: implement delete
      return null;
    } else {
      throw ArgumentError('document must be a JsonApiDocument');
    }
  }
}
