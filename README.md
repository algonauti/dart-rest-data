# rest_data

The goal of this package is to make interaction with your REST APIs pleasant and concise. It currently supports [JSON:API](https://jsonapi.org/)-compliant REST APIs, but can be extended to support more formats - and you're encouraged to contribute!

## Introduction

`rest_data` is inspired by [ember-data](https://github.com/emberjs/data) so it's based on 3 main abstractions:

* `Model`: represents a single REST resource, with its attributes and relationships.
* `Serializer`: takes care of transforming `Model` objects into your REST API payloads format (usually JSON), and vice-versa.
* `Adapter`: provides methods to read/write model objects to your REST APIs; it maps to `ember-data`'s [Store](https://api.emberjs.com/ember-data/release/classes/Store) but we choose to not adopt the name `Store` in order to avoid conflict with the popular dart package `redux`.

## Usage with a `JSON:API` backend

### Instantiating the Adapter

Create your `Adapter` as follows:

```dart
Adapter adapter = JsonApiAdapter('host.example.com', '/path/to/rest/api');
```

This is designed to be a long-lived object: a good practice is to wrap it in a singleton class to be used across the whole app, or to make it available throughout your app via Dependency Injection.

### Defining Models

For each of your REST API resources, you should define a model class extending `JsonApiModel` which provides the following getters:


 * `Map<String, dynamic> get attributes` see [specs](https://jsonapi.org/format/#document-resource-object-attributes)
 * `Map<String, dynamic> get relationships` see [specs](https://jsonapi.org/format/#document-resource-object-relationships)
* `Iterable<dynamic> get included` see [specs](https://jsonapi.org/format/#document-compound-documents)
* `Iterable<dynamic> get errors` see [specs](https://jsonapi.org/format/#error-objects)

together with helper methods (e.g. `idFor()`, `idsFor()`, `typeFor()`, `setHasOne()` etc. - see the source for more details).

Example model follows:

```dart
class Address extends JsonApiModel {
  // Constructors

  Address(JsonApiDocument doc) : super(doc);
  Address.init(String type) : super.init(type);

  // Attributes

  String get street => attributes['street'];
  set street(String value) => attributes['street'] = value;

  String get city => attributes['city'];
  set city(String value) => attributes['city'] = value;

  String get zip => attributes['zip'];
  set zip(String value) => attributes['zip'] = value;

  // Has-One Relationships

  String get countryId => idFor('country');
  set country(Country model) => setHasOne('country', model);
}  

class Country extends JsonApiModel {
  Country(JsonApiDocument doc) : super(doc);
}
```

### Reading

Invoking REST APIs is as simple as calling `async` methods on your `adapter` object. Such methods return one or more `JsonApiDocument` objects, which can be used to build your model objects.

#### Finding a specific record

```dart
var address = Address(await adapter.find('addresses', '1'));
```

Will send the request: `GET /addresses/1`.

#### Finding all records

```dart
Iterable<Country> countries = 
  adapter.findAll('countries')
  .map<Country>((jsonApiDoc) => Country(jsonApiDoc));
```

Will send the request: `GET /countries`.

#### Finding N specific records

```dart
Iterable<Address> addresses = 
  (await adapter.findMany('addresses', ['1', '2', '3']))
  .map<Address>((jsonApiDoc) => Address(jsonApiDoc));
```

`GET /addresses?filter[id]=1,2,3`

#### Querying

```dart
Iterable<Address> addresses = 
  (await adapter.query('addresses', {'q': 'miami'}))
  .map<Address>((jsonApiDoc) => Address(jsonApiDoc));
```

`GET /addresses?filter[q]=miami`


### Writing

#### Create

You'll start with an empty model object, whose attributes and relationships will be set based on user input:

```dart
var address = Address.init();
address.street = '9674 Northwest 10th Avenue';
address.city = 'Miami';
address.zip = '33150';
address.country = Country.peek('US');  // Assume all countries are cached, see "Caching" section later
```

To persist your model on your REST API backend, just invoke the `Adapter`'s `save()` method, which will return a new `Address` object:

```dart
var savedAddress = Address(await adapter.save(endpoint, address.jsonApiDoc));
```

The above line will send the request: `POST /addresses` with the `address` model object serialized as a [JSON:API Document](https://jsonapi.org/format/#document-structure).

#### Update

Assume you have an existing model object, and you edit some attributes based on user input:

```dart
var address = Address(await adapter.find('addresses', '1'));
address.street = '9674 Northwest 10th Avenue';
address.zip = '33150';
```

To persist your model on your REST API backend, just invoke the `Adapter`'s `save()` method, which will return a new `Address` object:

```dart
var savedAddress = Address(await adapter.save(endpoint, address.jsonApiDoc));
```

The above line will send the request: `PUT /addresses` with the `address` model object serialized as a [JSON:API Document](https://jsonapi.org/format/#document-structure).


### Caching

`JsonApiAdapter` comes with a basic caching mechanism built-in: a simple `Map` in-memory. Models fetched from the backend are automatically cached on any read request, and the cached ones are returned on subsequent read requests for the same model id. 

When you only want already cached data, you can use `Adapter`'s methods starting with the `peek` prefix.

Invalidation must be handled manually, passing `forceReload = true` to `find*` methods.
