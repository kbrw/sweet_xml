## Changelog

## 0.6.5

* small bugfix : unexpected :halted of enumerable

## 0.6.4

* make it compatible with Elixir 1.4

## 0.6.3

* bugfix: xpath `optional` with cast and void should return nil
* add "soft" uppercase cast modifier : put defaut value if type 
  modifier is uppercase "",0,0.0
* if "soft" and "optional", then return nil with value not compatible

## 0.6.1

* bugfix: xpath `list` modifier should always return a list

## 0.6.0

* text() xml nodes are now joined with the `s` modifier
* `transform_by` function allows you to customize each mapped field
  with any function

## 0.5.0

* Added support to optional modifier
* Update elixir requirement
* Map refactoring, from if/else tree to cleaner pattern matching
* Add casting capabilities
* Fix dependencies : doc deps only for :dev and otp "xmerl" dependency 

## 0.4.0

* Added support to map into keyword list instead of maps

## 0.3.0

* Added support to return values as strings (viniciussbs)

* Fix stream :halt handling (awetzel)

## 0.2.0

* Fixed encoding issue and improved speed (awetzel)

* Added file streaming support (awetzel)

* Added element streaming (awetzel)

* Added support for scalar values (xbrukner)
