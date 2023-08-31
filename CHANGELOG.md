# Changelog

## [0.7.4]

### Changed

* Contribution from [@thbar](https://github.com/thbar):
  * Logger deprecation warning fixed for Elixir 1.15 (`#94`)
  * Now requires Elixir 1.12+ (`#94`)

## [0.7.3] (2022-04-11)

### Changed

* Handling the option `{:rules, _}` ourselve, as well as partially the option `{:rules, _, _, _}`.
  When nothing is given, a new table is created, and destroyed after.
  If a table is given, and a DTD option is chosen, the table is reused for the DTD handling.
  If a custom `{:rules, _, _, _}` is given, and a restrictive DTD option is chosen, the custome rule will be overriden.
  Because of this mutual exclusivity (reconciling the behaviors is not possible via composition), it is recommended that you handle the DTD
  problem by yourself. You can see the issue `#71` for ideas.
  See the issue `#41` for more details on why this change happened. (Ets leaks.)

## [0.7.2] (2021-11-25)

### Changed

* Improvement on the doc, notably warning that only XPath 1.0 queries are handled.

### Added

* Contribution from [@tank-bohr](https://github.com/github/tank-bohr): Added strict stream API with a more coherent overall behavior, and easier to handle failure behavior:
  `stream!/2` and `stream_tags!/2,3` are now available.

## [0.7.1] (2021-08-25)

### Changed

* [@J3RN](https://github.com/J3RN) noticed a breaking change due to the introduction of an opaque type  
  Changed `xmlElement` from `@opaque` to `@type`

## [0.7.0] (2021-07-02)

### Changed

* Improvement on the doc

### Added

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

---

Changelog format inspired by [keep-a-changelog](https://github.com/olivierlacan/keep-a-changelog)

[unreleased]: https://github.com/kbrw/sweet_xml/compare/v0.7.4...HEAD

[0.7.4]: https://github.com/kbrw/sweet_xml/compare/v0.7.3...v0.7.4
[0.7.3]: https://github.com/kbrw/sweet_xml/compare/v0.7.2...v0.7.3
[0.7.2]: https://github.com/kbrw/sweet_xml/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/kbrw/sweet_xml/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/kbrw/sweet_xml/compare/0.6.6...v0.7.0
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
