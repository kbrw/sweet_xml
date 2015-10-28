# SweetXml [![Build Status](https://api.travis-ci.org/awetzel/sweet_xml.svg)][Continuous Integration]

[Continuous Integration]: http://travis-ci.org/awetzel/sweet_xml "Build status by Travis-CI"

`SweetXml` is a thin wrapper around `:xmerl`. It allows you to convert a
`char_list` or `xmlElement` record as defined in `:xmerl` to an elixir value such
as `map`, `list`, `string`, `integer`, or any combination of these.


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

     'k' stands for (K)eyword. This forces `xpath/2` to return a Keyword instead of a Map.

  * `~x"//some/path"el` - mix of the above

  * `~x"//some/path"s`

    's' stands for (s)tring. This forces `xpath/2` to return the value as
    string instead of a char list.

  * `x"//some/path"o`

    'o' stands for (O)ptional. This allows the path to not exist, and will return nil.

  * `~x"//some/path"sl` - string list.

  * `~x"//some/path"i`

    'i' stands for (i)nteger. This forces `xpath/2` to return the value as
    integer instead of a char list.

  * `~x"//some/path"il` - integer list.

Also in the examples section, we always import SweetXml first. This
makes `x_sigil` available in the current scope. Without it, instead of using
`~x`, you can use the `%SweetXpath` struct

```elixir
assert ~x"//some/path"e == %SweetXpath{path: '//some/path', is_value: false, is_list: false, cast_to: false}
```

Note the use of char_list in the path definition.

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
