# Changelog

## [Unreleased]

### Changed

* Improvement on the doc

### ADDED

* Added option to raise on DTD definitions

## [0.6.6] (2019-02-24)

* small bugfix: Fix compilation warnings on newer versions of Elixir
* doc updates


## [0.6.5] (2017-02-08)

* small bugfix : unexpected `:halted` of enumerable

## [0.6.4] (2017-01-17)

* make it compatible with Elixir 1.4

## [0.6.3] (2016-12-14)

* bugfix: xpath `optional` with cast and void should return nil
* add "soft" uppercase cast modifier : put default value if type
  modifier is uppercase "",0,0.0
* if "soft" and "optional", then return nil with value not compatible

## [0.6.1] (2016-02-10)

* bugfix: xpath `list` modifier should always return a list

## [0.6.0] (2016-02-09)

* text() XML nodes are now joined with the `s` modifier
* `transform_by` function allows you to customize each mapped field
  with any function

## [0.5.1] (2016-02-08)

## [0.5.0] (2015-10-28)

* Added support to optional modifier
* Update Elixir requirement
* Map refactoring, from if/else tree to cleaner pattern matching
* Add casting capabilities
* Fix dependencies : doc deps only for `:dev` and OTP `:xmerl` dependency

## [0.4.0] (2015-09-11)

* Added support to map into keyword list instead of maps

## [0.3.0] (2015-08-10)

* Added support to return values as strings (viniciussbs)

* Fix stream `:halt` handling (awetzel)

## [0.2.1] (2016-04-12)

## [0.2.0] (2016-04-11)

* Fixed encoding issue and improved speed (awetzel)

* Added file streaming support (awetzel)

* Added element streaming (awetzel)

* Added support for scalar values (xbrukner)

## [0.1.1]

[unreleased]: https://github.com/kbrw/sweet_xml/compare/0.6.6...HEAD
[0.6.6]: https://github.com/kbrw/sweet_xml/compare/0.6.5...0.6.6
[0.6.5]: https://github.com/kbrw/sweet_xml/compare/0.6.4...0.6.5
[0.6.4]: https://github.com/kbrw/sweet_xml/compare/0.6.3...0.6.4
[0.6.3]: https://github.com/kbrw/sweet_xml/compare/0.6.2...0.6.3
[0.6.2]: https://github.com/kbrw/sweet_xml/compare/0.6.1...0.6.2
[0.6.1]: https://github.com/kbrw/sweet_xml/compare/0.6.0...0.6.1
[0.6.0]: https://github.com/kbrw/sweet_xml/compare/0.5.1...0.6.0
[0.5.1]: https://github.com/kbrw/sweet_xml/compare/0.5.0...0.5.1
[0.5.0]: https://github.com/kbrw/sweet_xml/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/kbrw/sweet_xml/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/kbrw/sweet_xml/compare/0.2.1...0.3.0
[0.2.1]: https://github.com/kbrw/sweet_xml/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/kbrw/sweet_xml/compare/0.1.1...0.2.0
[0.1.1]: https://github.com/kbrw/sweet_xml/compare/f203bdf...0.1.1
