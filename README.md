# SweetXml [![Build Status](https://api.travis-ci.org/kbrw/sweet_xml.svg)][Continuous Integration]

[Continuous Integration]: http://travis-ci.org/kbrw/sweet_xml "Build status by Travis-CI"

`SweetXml` is a thin wrapper around `:xmerl`. It allows you to convert a
`char_list` or `xmlElement` record as defined in `:xmerl` to an elixir value such
as `map`, `list`, `string`, `integer`, `float` or any combination of these.


## Examples

Given a xml document such as below

```xml
<?xml version="1.05" encoding="UTF-8"?>
<game>
  <matchups>
    <matchup winner-id="1">
      <name>Match One</name>
      <teams>
        <team>
          <id>1</id>
          <name>Team One</name>
        </team>
        <team>
          <id>2</id>
          <name>Team Two</name>
        </team>
      </teams>
    </matchup>
    <matchup winner-id="2">
      <name>Match Two</name>
      <teams>
        <team>
          <id>2</id>
          <name>Team Two</name>
        </team>
        <team>
          <id>3</id>
          <name>Team Three</name>
        </team>
      </teams>
    </matchup>
    <matchup winner-id="1">
      <name>Match Three</name>
      <teams>
        <team>
          <id>1</id>
          <name>Team One</name>
        </team>
        <team>
          <id>3</id>
          <name>Team Three</name>
        </team>
      </teams>
    </matchup>
  </matchups>
</game>
```
We can do the following

```elixir
import SweetXml
doc = "..." # as above
```

get the name of the first match

```elixir
result = doc |> xpath(~x"//matchup/name/text()") # `sigil_x` for (x)path
assert result == 'Match One'
```

get the xml record of the name of the first match

```elixir
result = doc |> xpath(~x"//matchup/name"e) # `e` is the modifier for (e)ntity
assert result == {:xmlElement, :name, :name, [], {:xmlNamespace, [], []},
        [matchup: 2, matchups: 2, game: 1], 2, [],
        [{:xmlText, [name: 2, matchup: 2, matchups: 2, game: 1], 1, [],
          'Match One', :text}], [],
        ...}
```

get the full list of matchup name

```elixir
result = doc |> xpath(~x"//matchup/name/text()"l) # `l` stands for (l)ist
assert result == ['Match One', 'Match Two', 'Match Three']
```

get a list of winner-id by attributes

```elixir
result = doc |> xpath(~x"//matchup/@winner-id"l)
assert result == ['1', '2', '1']
```

get a list of matchups with different map structure

```elixir
result = doc |> xpath(
  ~x"//matchups/matchup"l,
  name: ~x"./name/text()",
  winner: [
    ~x".//team/id[.=ancestor::matchup/@winner-id]/..",
    name: ~x"./name/text()"
  ]
)
assert result == [
  %{name: 'Match One', winner: %{name: 'Team One'}},
  %{name: 'Match Two', winner: %{name: 'Team Two'}},
  %{name: 'Match Three', winner: %{name: 'Team One'}}
]
```

Or directly return a mapping of your liking

```elixir
result = doc |> xmap(
  matchups: [
    ~x"//matchups/matchup"l,
    name: ~x"./name/text()",
    winner: [
      ~x".//team/id[.=ancestor::matchup/@winner-id]/..",
      name: ~x"./name/text()"
    ]
  ],
  last_matchup: [
    ~x"//matchups/matchup[last()]",
    name: ~x"./name/text()",
    winner: [
      ~x".//team/id[.=ancestor::matchup/@winner-id]/..",
      name: ~x"./name/text()"
    ]
  ]
)
assert result == %{
  matchups: [
    %{name: 'Match One', winner: %{name: 'Team One'}},
    %{name: 'Match Two', winner: %{name: 'Team Two'}},
    %{name: 'Match Three', winner: %{name: 'Team One'}}
  ],
  last_matchup: %{name: 'Match Three', winner: %{name: 'Team One'}}
}
```

## The ~x Sigil

In the above examples, we used the expression `~x"//some/path"` to
define the path. The reason is it allows us to more precisely specify what
is being returned.

  * `~x"//some/path"`

    without any modifiers, `xpath/2` will return the value of the entity if
    the entity is of type `xmlText`, `xmlAttribute`, `xmlPI`, `xmlComment`
    as defined in `:xmerl`

  * `~x"//some/path"e`

    `e` stands for (e)ntity. This forces `xpath/2` to return the entity with
    which you can further chain your `xpath/2` call

  * `~x"//some/path"l`

    'l' stands for (l)ist. This forces `xpath/2` to return a list. Without
    `l`, `xpath/2` will only return the first element of the match

  * `~x"//some/path"k`

     'k' stands for (k)eyword. This forces `xpath/2` to return a Keyword instead of a Map.

  * `~x"//some/path"el` - mix of the above

  * `~x"//some/path"s`

    's' stands for (s)tring. This forces `xpath/2` to return the value as
    string instead of a char list.

  * `~x"//some/path"S`

    'S' stands for soft (S)tring. This forces `xpath/2` to return the value as
    string instead of a char list, but if node content is incompatible with a string,
    set `""`.

  * `x"//some/path"o`

    'o' stands for (o)ptional. This allows the path to not exist, and will return nil.

  * `~x"//some/path"sl` - string list.

  * `~x"//some/path"i`

    'i' stands for (i)nteger. This forces `xpath/2` to return the value as
    integer instead of a char list.

  * `~x//some/path"I`

    'I' stands for soft (I)nteger. This forces `xpath/2` to return the value as
    integer instead of a char list, but if node content is incompatible with an integer, 
    set `0`.
    
  * `~x"//some/path"f`

    'f' stands for (f)loat. This forces `xpath/2` to return the value as
    float instead of a char list.

  * `~x//some/path"F`

    'F' stands for soft (F)loat. This forces `xpath/2` to return the value as
    float instead of a char list, but if node content is incompatible with a float, 
    set `0.0`.

  * `~x"//some/path"il` - integer list.

If you use the *optional* modifier `o` together with a *soft* cast modifier
(uppercase), then the value is set to `nil` when the value is not compatible
for instance `~x//some/path/text()"Fo` return `nil` if the text is not a number.

Also in the examples section, we always import SweetXml first. This
makes `x_sigil` available in the current scope. Without it, instead of using
`~x`, you can use the `%SweetXpath` struct

```elixir
assert ~x"//some/path"e == %SweetXpath{path: '//some/path', is_value: false, is_list: false, cast_to: false}
```

Note the use of char_list in the path definition.

## Namespace support

Given a xml document such as below

```xml
<?xml version="1.05" encoding="UTF-8"?>
<game xmlns="http://example.com/fantasy-league" xmlns:ns1="http://example.com/baseball-stats">
  <matchups>
    <matchup winner-id="1">
      <name>Match One</name>
      <teams>
        <team>
          <id>1</id>
          <name>Team One</name>
          <ns1:runs>5</ns1:runs>
        </team>
        <team>
          <id>2</id>
          <name>Team Two</name>
          <ns1:runs>2</ns1:runs>
        </team>
      </teams>
    </matchup>
  </matchups>
</game>
```

We can do the following

```elixir
import SweetXml
xml_str = "..." # as above
doc = parse(xml_str, namespace_conformant: true)
```

Note the fact that we explicitly parse the XML with the `namespace_conformant:
true` option. This is needed to allow nodes to be identified in a prefix
independent way.

We can use namespace prefixes of our preference, regardless of what prefix is
used in the document:

```elixir
result = doc
  |> xpath(~x"//ff:matchup/ff:name/text()"
           |> add_namespace("ff", "http://example.com/fantasy-league"))

assert result == 'Match One'
```

We can specify multiple namespace prefixes: 

```elixir
result = doc
  |> xpath(~x"//ff:matchup//bb:runs/text()"
           |> add_namespace("ff", "http://example.com/fantasy-league")
           |> add_namespace("bb", "http://example.com/baseball-stats"))

assert result == '5'
```


## From Chaining to Nesting

Here's a brief explanation to how nesting came about.

### Chaining

Both `xpath` and `xmap` can take an `:xmerl` xml record as the first argment.
Therefore you can chain calls to these functions like below:

```elixir
doc
|> xpath(~x"//li"l)
|> Enum.map fn (li_node) ->
  %{
    name: li_node |> xpath(~x"./name/text()"),
    age: li_node |> xpath(~x"./age/text()")
  }
end
```

### Mapping to a structure

Since the previous example is such a common use case, SweetXml allows you just
simply do the following

```elixir
doc
|> xpath(
  ~x"//li"l,
  name: ~x"./name/text()",
  age: ~x"./age/text()"
)
```

### Nesting

But what you want is sometimes more complex than just that, SweetXml thus also
allows nesting

```elixir
doc
|> xpath(
  ~x"//li"l,
  name: [
    ~x"./name",
    first: ~x"./first/text()",
    last: ~x"./last/text()"
  ],
  age: ~x"./age/text()"
)
```

### Transform By

Sometimes we need to transform the value to what we need, SweetXml supports that
via `transform_by/2`

```elixir
doc = "<li><name><first>john</first><last>doe</last></name><age>30</age></li>"

result = doc |> xpath(
  ~x"//li"l,
  name: [
    ~x"./name",
    first: ~x"./first/text()"s |> transform_by(&String.capitalize/1),
    last: ~x"./last/text()"s |> transform_by(&String.capitalize/1)
  ],
  age: ~x"./age/text()"i
)

^result = [%{age: 30, name: %{first: "John", last: "Doe"}}]
```

The same can be used to break parsing code into reusable functions that can be
used in nesting

```elixir
doc = "<li><name><first>john</first><last>doe</last></name><age>30</age></li>"

parse_name = fn xpath_node ->
  xpath_node |> xmap(
    first: ~x"./first/text()"s |> transform_by(&String.capitalize/1),
    last: ~x"./last/text()"s |> transform_by(&String.capitalize/1)
  )
end

result = doc |> xpath(
  ~x"//li"l,
  name: ~x"./name" |> transform_by(parse_name),
  age: ~x"./age/text()"i
)

^result = [%{age: 30, name: %{first: "John", last: "Doe"}}]
```

For more examples, please take a look at the tests and help.

## Streaming

`SweetXml` now also supports streaming in various forms. Here's a sample xml doc.
Notice the certain lines have xml tags that span multiple lines.

```xml
<?xml version="1.05" encoding="UTF-8"?>
<html>
  <head>
    <title>XML Parsing</title>
    <head><title>Nested Head</title></head>
  </head>
  <body>
    <p>Neato €</p><ul>
      <li class="first star" data-index="1">
        First</li><li class="second">Second
      </li><li
            class="third">Third</li>
    </ul>
    <div>
      <ul>
        <li>Forth</li>
      </ul>
    </div>
    <special_match_key>first star</special_match_key>
  </body>
</html>
```

### Working with `File.stream!`

Working with streams is exactly the same as working with binaries.

```elixir
File.stream!("file_above.xml") |> xpath(...)
```

### `SweetXml` element streaming

Once you have a file stream, you may not want to work with the entire document to
save memory.

```elixir
file_stream = File.stream!("file_above.xml")

result = file_stream
|> stream_tags([:li, :special_match_key])
|> Stream.map(fn
    {_, doc} ->
      xpath(doc, ~x"./text()")
  end)
|> Enum.to_list

assert result == ['\n        First', 'Second\n      ', 'Third', 'Forth', 'first star']
```


:warning: In case of large document, you may want to use the `discard` option to avoid memory leak.

```elixir
result = file_stream
|> stream_tags([:li, :special_match_key], discard: [:li, :special_match_key])
```
