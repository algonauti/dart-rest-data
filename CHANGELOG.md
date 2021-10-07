## [1.1.0] - Oct 7th, 2021

* Fine-tuning after automatic migration to null safety
* Introduced `getAttribute<T>()` and `setAttribute<T>()` methods

## [1.0.0] - Aug 19th, 2021

* Migrated to null safety

## [0.4.0] - July 2nd, 2021

* `JsonApiAdapter` accepts an optional `useSSL` boolean argument (default: `true`).
* Added method to clear has-one relationship: `clearHasOne()`
* Removed author field from `pubspec.yml` (now deprecated)
* Upgraded dependencies
* Increased minimum Dart SDK to 2.11.0 (the latest one before null-safety)

## [0.3.4] - May 6th, 2021

* Upgraded dependencies

## [0.3.3] - April 21th, 2021

* Fixed bug with `setHasOne()` method in `JsonApiAdapter`
* Updated `List` initialization according to recent Dart 

## [0.3.2] - December 6th, 2020

* Upgraded dependencies
* Fixed bug with `findMany()` method in `JsonApiAdapter` 

## [0.3.1] - June 29th, 2020

* Upgraded dependencies
* Fixed Dart deprecation

## [0.3.0] - March 19th, 2020

* Added library name
* Upgraded dependencies
* Improved extensibility of `JsonApiAdapter`
* Let `JsonApiSerializer` optionally serialize included records
* Added `endpoint` computed property and `addErrorFor()` to `JsonApiModel`
* Added `hasMeta` computed property to `JsonApiManyModel`

## [0.2.1] - January 31st, 2020

* Fixed bug with `JSON:API` included docs
* Upgraded dependencies

## [0.2.0] - December 3rd, 2019

* Upgraded `equatable` to `1.0.1`

## [0.1.1] - November 26th, 2019

* Improved code after `pub.dev` analysis

## [0.1.0] - November 26th, 2019

* Initial release, works with any `JSON:API` backend
