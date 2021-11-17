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
            'null_attribute': null,
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

  group('getAttribute()', () {
    Model model = JsonApiModel(createJsonApiDocument());

    group('List<String>', () {
      test('non-null', () {
        var value = model.getAttribute<List<String>>('attribute_list_string');
        expect(value, isA<List<String>>());
        List<String> list = value.cast<String>();
        expect(list.length, 2);
      });

      test('null', () {
        var value = model.getAttribute<List<String>>('null_attribute');
        expect(value, isA<List<String>>());
        List<String> list = value.cast<String>();
        expect(list.isEmpty, true);
      });
    });

    group('List<bool>', () {
      test('non-null', () {
        var value = model.getAttribute<List<bool>>('attribute_list_bool');
        expect(value, isA<List<bool>>());
        List<bool> list = value.cast<bool>();
        expect(list.length, 2);
      });

      test('null', () {
        var value = model.getAttribute<List<bool>>('null_attribute');
        expect(value, isA<List<bool>>());
        List<bool> list = value.cast<bool>();
        expect(list.isEmpty, true);
      });
    });

    group('List<int>', () {
      test('non-null', () {
        var value = model.getAttribute<List<int>>('attribute_list_int');
        expect(value, isA<List<int>>());
        List<int> list = value.cast<int>();
        expect(list.length, 2);
      });

      test('null', () {
        var value = model.getAttribute<List<int>>('null_attribute');
        expect(value, isA<List<int>>());
        List<int> list = value.cast<int>();
        expect(list.isEmpty, true);
      });
    });

    group('List<double>', () {
      test('non-null', () {
        var value = model.getAttribute<List<double>>('attribute_list_double');
        expect(value, isA<List<double>>());
        List<double> list = value.cast<double>();
        expect(list.length, 2);
      });

      test('null', () {
        var value = model.getAttribute<List<double>>('null_attribute');
        expect(value, isA<List<double>>());
        List<double> list = value.cast<double>();
        expect(list.isEmpty, true);
      });
    });
  });
}
