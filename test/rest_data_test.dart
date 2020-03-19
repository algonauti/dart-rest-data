import 'package:rest_data/rest_data.dart';
import 'package:test/test.dart';

void main() {
  var createJsonApiDocument =
      () => JsonApiDocument('unique_ID_1', 'model_type_1', {
            'attribute_one': 'value_one',
            'attribute_two': 'value_two',
          }, {
            'has_one_relationship': {
              'data': {'id': 'unique_ID_2', 'type': 'model_type_2'}
            },
            'has_many_relationhip': {
              'data': [
                {'id': 'unique_ID_3', 'type': 'job_assignments'},
                {'id': 'unique_ID_4', 'type': 'job_assignments'},
              ]
            },
          });

  test('create a new JsonApiDocument', () {
    expect(createJsonApiDocument(), TypeMatcher<JsonApiDocument>());
  });

  test('create a new JsonApiModel', () {
    Model model = JsonApiModel(createJsonApiDocument());
    expect(model, TypeMatcher<JsonApiModel>());
  });

  test('create a new JsonApiAdapter', () {
    Adapter adapter = JsonApiAdapter('host.example.com', '/path/to/rest/api');
    expect(adapter, TypeMatcher<JsonApiAdapter>());
  });
}
