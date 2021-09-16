import 'package:rest_data/rest_data.dart';
import 'package:test/test.dart';

void main() {
  var createJsonApiDocument =
      () => JsonApiDocument('unique_ID_1', 'model_type_1', {
            'attribute_one': 'value_one',
            'attribute_two': 'value_two',
            'attribute_list_string': ['one', 'two'],
            'attribute_list_bool': [true, false],
            'attribute_list_int': [1, 2],
            'attribute_list_double': [0.0, -2.5],
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

  test('access List attributes', () {
    Model model = JsonApiModel(createJsonApiDocument());
    expect(
      model.getAttribute<List<String>>('attribute_list_string'),
      isA<List<String>>(),
    );
    expect(
      model.getAttribute<List<bool>>('attribute_list_bool'),
      isA<List<bool>>(),
    );
    expect(
      model.getAttribute<List<int>>('attribute_list_int'),
      isA<List<int>>(),
    );
    expect(
      model.getAttribute<List<double>>('attribute_list_double'),
      isA<List<double>>(),
    );
  });
}
