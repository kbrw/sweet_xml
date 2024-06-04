defmodule SweetXmlTest do
  use ExUnit.Case, async: false
  doctest SweetXml

  import SweetXml

  setup do
    simple = File.read!("./test/files/simple.xml")
    complex = File.read!("./test/files/complex.xml")
    complex_stream = File.stream!("./test/files/complex.xml")
    simple_stream = File.stream!("./test/files/simple_stream.xml")
    readme = File.read!("test/files/readme.xml")
    namespaces = File.read!("test/files/namespaces.xml")
    float_sigil = File.read!("test/files/float.xml")

    {:ok,
     [
       simple: simple,
       complex: complex,
       readme: readme,
       complex_stream: complex_stream,
       simple_stream: simple_stream,
       namespaces: namespaces,
       float_sigil: float_sigil
     ]}
  end

  test "parse", %{simple: doc} do
    result = doc |> parse
    assert xmlElement(result, :name) == :html
  end

  test "use parse with a stream", %{complex_stream: complex_stream} do
    result = complex_stream |> parse
    assert xmlElement(result, :name) == :fantasy_content
  end

  test "xpath sigil" do
    assert ~x"//header/text()" == %SweetXpath{
             path: ~c"//header/text()",
             is_value: true,
             is_list: false,
             is_keyword: false,
             cast_to: false
           }

    assert ~x"//header/text()"e == %SweetXpath{
             path: ~c"//header/text()",
             is_value: false,
             is_list: false,
             is_keyword: false,
             cast_to: false
           }

    assert ~x"//header/text()"l == %SweetXpath{
             path: ~c"//header/text()",
             is_value: true,
             is_list: true,
             is_keyword: false,
             cast_to: false
           }

    assert ~x"//header/text()"k == %SweetXpath{
             path: ~c"//header/text()",
             is_value: true,
             is_list: false,
             is_keyword: true,
             cast_to: false
           }

    assert ~x"//header/text()"s == %SweetXpath{
             path: ~c"//header/text()",
             is_value: true,
             is_list: false,
             is_keyword: false,
             cast_to: :string
           }

    assert ~x"//header/text()"i == %SweetXpath{
             path: ~c"//header/text()",
             is_value: true,
             is_list: false,
             is_keyword: false,
             cast_to: :integer
           }

    assert ~x"//header/text()"f == %SweetXpath{
             path: ~c"//header/text()",
             is_value: true,
             is_list: false,
             is_keyword: false,
             cast_to: :float
           }

    assert ~x"//header/text()"el == %SweetXpath{
             path: ~c"//header/text()",
             is_value: false,
             is_list: true,
             is_keyword: false,
             cast_to: false
           }

    assert ~x"//header/text()"le == %SweetXpath{
             path: ~c"//header/text()",
             is_value: false,
             is_list: true,
             is_keyword: false,
             cast_to: false
           }

    assert ~x"//header/text()"sl == %SweetXpath{
             path: ~c"//header/text()",
             is_value: true,
             is_list: true,
             is_keyword: false,
             cast_to: :string
           }

    assert ~x"//header/text()"ls == %SweetXpath{
             path: ~c"//header/text()",
             is_value: true,
             is_list: true,
             is_keyword: false,
             cast_to: :string
           }

    assert ~x"//header/text()"il == %SweetXpath{
             path: ~c"//header/text()",
             is_value: true,
             is_list: true,
             is_keyword: false,
             cast_to: :integer
           }

    assert ~x"//header/text()"li == %SweetXpath{
             path: ~c"//header/text()",
             is_value: true,
             is_list: true,
             is_keyword: false,
             cast_to: :integer
           }
  end

  test "xpath with sweet_xpath as only argument", %{simple: doc} do
    result = doc |> xpath(~x"//header/text()"e)
    assert xmlText(result, :value) == ~c"Content Header"

    result = doc |> xpath(~x"//header/text()")
    assert result == ~c"Content Header"

    result = doc |> xpath(~x"//header/text()"s)
    assert result == "Content Header"

    result = doc |> xpath(~x"//span[contains(@class,'badge')][@data-attr='first-half']/text()"l)
    assert result == [~c"One", ~c"Two", ~c"Three", ~c"Four", ~c"Five"]

    result = doc |> xpath(~x"//span[contains(@class,'badge')][@data-attr='first-half']/text()"ls)
    assert result == ["One", "Two", "Three", "Four", "Five"]

    result = doc |> xpath(~x"//span[contains(@class,'badge')][@data-attr='first-half']/text()"le)
    assert length(result) == 5
    assert result |> List.first() |> xmlText(:value) == ~c"One"
  end

  test "xpath should return values for those entities that have values", %{simple: doc} do
    result = doc |> xpath(~x"//li/@class")
    assert result == ~c"first star"
    result = doc |> xpath(~x"//li/@data-index")
    assert result == ~c"1"
  end

  test "xmap with single level", %{simple: doc} do
    result =
      doc
      |> xmap(
        header: ~x"//header/text()",
        badges: ~x"//span[contains(@class,'badge')][@data-attr='first-half']/text()"l
      )

    assert result == %{
             header: ~c"Content Header",
             badges: [~c"One", ~c"Two", ~c"Three", ~c"Four", ~c"Five"]
           }
  end

  test "xmap with multiple level of spec", %{simple: doc} do
    result =
      doc
      |> xmap(
        html: [
          ~x"//html",
          body: [
            ~x"./body",
            first_list: [
              ~x"./ul/li"l,
              class: ~x"./@class",
              data_attr: ~x"./@data-attr",
              text: ~x"./text()"
            ]
          ]
        ]
      )

    assert result == %{
             html: %{
               body: %{
                 first_list: [
                   %{class: ~c"first star", data_attr: nil, text: ~c"First"},
                   %{class: ~c"second", data_attr: nil, text: ~c"Second"},
                   %{class: ~c"third", data_attr: nil, text: ~c"Third"}
                 ]
               }
             }
           }

    result =
      doc
      |> xpath(
        ~x"//html",
        body: [
          ~x"./body",
          first_list: [
            ~x"./ul/li"l,
            class: ~x"./@class",
            data_attr: ~x"./@data-attr",
            text: ~x"./text()"
          ]
        ]
      )

    assert result == %{
             body: %{
               first_list: [
                 %{class: ~c"first star", data_attr: nil, text: ~c"First"},
                 %{class: ~c"second", data_attr: nil, text: ~c"Second"},
                 %{class: ~c"third", data_attr: nil, text: ~c"Third"}
               ]
             }
           }
  end

  test "xpath with multiple level of spec from stream", %{simple_stream: simple_stream} do
    result =
      simple_stream
      |> xmap(
        html: [
          ~x"//html",
          body: [
            ~x"./body",
            first_list: [
              ~x"./ul/li"l,
              class: ~x"./@class",
              data_attr: ~x"./@data-attr",
              text: ~x"./text()"
            ]
          ]
        ]
      )

    assert result == %{
             html: %{
               body: %{
                 first_list: [
                   %{class: ~c"first star", data_attr: nil, text: ~c"\n        First"},
                   %{class: ~c"second", data_attr: nil, text: ~c"Second\n      "},
                   %{class: ~c"third", data_attr: nil, text: ~c"Third"}
                 ]
               }
             }
           }

    result =
      simple_stream
      |> xpath(
        ~x"//html",
        body: [
          ~x"./body",
          first_list: [
            ~x"./ul/li"l,
            class: ~x"./@class",
            data_attr: ~x"./@data-attr",
            text: ~x"./text()"
          ]
        ]
      )

    assert result == %{
             body: %{
               first_list: [
                 %{class: ~c"first star", data_attr: nil, text: ~c"\n        First"},
                 %{class: ~c"second", data_attr: nil, text: ~c"Second\n      "},
                 %{class: ~c"third", data_attr: nil, text: ~c"Third"}
               ]
             }
           }
  end

  test "reuse returned nodes", %{simple: doc} do
    result =
      doc
      |> xpath(~x"//li"l)
      |> Enum.map(&(&1 |> xpath(~x"./text()")))

    assert result == [~c"First", ~c"Second", ~c"Third", ~c"Forth"]
  end

  test "complex parsing", %{complex: doc} do
    result =
      doc
      |> xmap(
        matchups: [
          ~x"//matchups/matchup/is_tied[contains(., '0')]/.."l,
          week: ~x"./week/text()",
          winner: [
            ~x"./teams/team/team_key[.=ancestor::matchup/winner_team_key]/..",
            name: ~x"./name/text()",
            key: ~x"./team_key/text()"
          ],
          loser: [
            ~x"./teams/team/team_key[.!=ancestor::matchup/winner_team_key]/..",
            name: ~x"./name/text()",
            key: ~x"./team_key/text()"
          ],
          teams: [
            ~x"./teams/team"l,
            name: ~x"./name/text()",
            key: ~x"./team_key/text()"
          ]
        ]
      )

    assert result == %{
             matchups: [
               %{
                 week: ~c"16",
                 winner: %{name: ~c"Asgardian Warlords", key: ~c"273.l.239541.t.1"},
                 loser: %{name: ~c"yourgoindown220", key: ~c"273.l.239541.t.2"},
                 teams: [
                   %{name: ~c"Asgardian Warlords", key: ~c"273.l.239541.t.1"},
                   %{name: ~c"yourgoindown220", key: ~c"273.l.239541.t.2"}
                 ]
               },
               %{
                 week: ~c"16",
                 winner: %{name: ~c"187 she wrote", key: ~c"273.l.239541.t.4"},
                 loser: %{name: ~c"bleedgreen", key: ~c"273.l.239541.t.6"},
                 teams: [
                   %{name: ~c"187 she wrote", key: ~c"273.l.239541.t.4"},
                   %{name: ~c"bleedgreen", key: ~c"273.l.239541.t.6"}
                 ]
               },
               %{
                 week: ~c"16",
                 winner: %{name: ~c"jo momma", key: ~c"273.l.239541.t.9"},
                 loser: %{name: ~c"Thunder Ducks", key: ~c"273.l.239541.t.5"},
                 teams: [
                   %{name: ~c"Thunder Ducks", key: ~c"273.l.239541.t.5"},
                   %{name: ~c"jo momma", key: ~c"273.l.239541.t.9"}
                 ]
               },
               %{
                 week: ~c"16",
                 winner: %{name: ~c"The Dude Abides", key: ~c"273.l.239541.t.10"},
                 loser: %{name: ~c"bingo_door", key: ~c"273.l.239541.t.8"},
                 teams: [
                   %{name: ~c"bingo_door", key: ~c"273.l.239541.t.8"},
                   %{name: ~c"The Dude Abides", key: ~c"273.l.239541.t.10"}
                 ]
               }
             ]
           }
  end

  test "complex parsing and processing", %{complex: doc} do
    result =
      doc
      |> xpath(
        ~x"//matchups/matchup/is_tied[contains(., '0')]/.."l,
        week: ~x"./week/text()",
        winner: [
          ~x"./teams/team/team_key[.=ancestor::matchup/winner_team_key]/..",
          name: ~x"./name/text()",
          key: ~x"./team_key/text()"
        ],
        loser: [
          ~x"./teams/team/team_key[.!=ancestor::matchup/winner_team_key]/..",
          name: ~x"./name/text()",
          key: ~x"./team_key/text()"
        ],
        "teams[]": [
          ~x"./teams/team"l,
          name: ~x"./name/text()",
          key: ~x"./team_key/text()"
        ]
      )
      |> Enum.reduce(%{}, fn matchup, stat ->
        winner_name = matchup[:winner][:name]
        loser_name = matchup[:loser][:name]
        stat = Map.put_new(stat, winner_name, %{wins: 0, loses: 0})
        stat = Map.put_new(stat, loser_name, %{wins: 0, loses: 0})

        {_, stat} = get_and_update_in(stat, [winner_name, :wins], &{&1, &1 + 1})
        {_, stat} = get_and_update_in(stat, [loser_name, :loses], &{&1, &1 + 1})

        stat
      end)

    assert result == %{
             ~c"Asgardian Warlords" => %{loses: 0, wins: 1},
             ~c"yourgoindown220" => %{loses: 1, wins: 0},
             ~c"187 she wrote" => %{loses: 0, wins: 1},
             ~c"Thunder Ducks" => %{loses: 1, wins: 0},
             ~c"The Dude Abides" => %{loses: 0, wins: 1},
             ~c"jo momma" => %{loses: 0, wins: 1},
             ~c"bleedgreen" => %{loses: 1, wins: 0},
             ~c"bingo_door" => %{loses: 1, wins: 0}
           }
  end

  test "read me examples", %{simple: simple, readme: readme} do
    # get the name of the first match
    # `x` marks sigil for (x)path
    result = readme |> xpath(~x"//matchup/name/text()")
    assert result == ~c"Match One"

    # get the xml record of the name of the first match
    # `e` is the modifier for (e)ntity
    result = readme |> xpath(~x"//matchup/name"e)
    assert elem(result, 0) == :xmlElement

    # get the full list of matchup name
    # `l` stands for (l)ist
    result = readme |> xpath(~x"//matchup/name/text()"l)
    assert result == [~c"Match One", ~c"Match Two", ~c"Match Three"]

    # get a list of matchups with different map structure
    result =
      readme
      |> xpath(
        ~x"//matchups/matchup"l,
        name: ~x"./name/text()",
        winner: [
          ~x".//team/id[.=ancestor::matchup/@winner-id]/..",
          name: ~x"./name/text()"
        ]
      )

    assert result == [
             %{name: ~c"Match One", winner: %{name: ~c"Team One"}},
             %{name: ~c"Match Two", winner: %{name: ~c"Team Two"}},
             %{name: ~c"Match Three", winner: %{name: ~c"Team One"}}
           ]

    # get a list of matchups with keyword structure preserving order defined in spec
    result =
      readme
      |> xpath(
        ~x"//matchups/matchup"lk,
        name: ~x"./name/text()",
        winner: [
          ~x".//team/id[.=ancestor::matchup/@winner-id]/..",
          name: ~x"./name/text()"
        ]
      )

    assert result == [
             [name: ~c"Match One", winner: %{name: ~c"Team One"}],
             [name: ~c"Match Two", winner: %{name: ~c"Team Two"}],
             [name: ~c"Match Three", winner: %{name: ~c"Team One"}]
           ]

    # get a map with lots of nesting
    result =
      simple
      |> xmap(
        html: [
          ~x"//html",
          body: [
            ~x"./body",
            p: ~x"./p[1]/text()",
            first_list: [
              ~x"./ul/li"l,
              class: ~x"./@class",
              data_attr: ~x"./@data-attr",
              text: ~x"./text()"
            ],
            second_list: ~x"./div//li/text()"l
          ]
        ],
        odd_badges_class_values: ~x"//span[contains(@class, 'odd')]/@class"l,
        special_match: ~x"//li[@class=ancestor::body/special_match_key]/text()"
      )

    assert result == %{
             html: %{
               body: %{
                 p: ~c"Neato €",
                 first_list: [
                   %{class: ~c"first star", data_attr: nil, text: ~c"First"},
                   %{class: ~c"second", data_attr: nil, text: ~c"Second"},
                   %{class: ~c"third", data_attr: nil, text: ~c"Third"}
                 ],
                 second_list: [~c"Forth"]
               }
             },
             odd_badges_class_values: [~c"first badge odd", ~c"badge odd"],
             special_match: ~c"First"
           }
  end

  test "XPath functions that return xmlObj", %{simple: simple} do
    # Get name of root tag
    result = simple |> xpath(~x"name(.)")

    assert result == ~c"html"

    # Get number of li elements
    result = simple |> xpath(~x"count(//li)")

    assert result == 4

    # True and false
    result = simple |> xpath(~x"true()")

    assert result == true

    result = simple |> xpath(~x"false()")

    assert result == false
  end

  test "xpath with route that doesn't exist", %{simple: simple} do
    assert xpath(simple, ~x"//ListBucketResult"o,
             name: ~x"./Name/text()"s,
             is_truncated: ~x"./IsTruncated/text()"s,
             owner: [
               ~x"./Owner",
               id: ~x"./ID/text()"s
             ]
           ) == nil
  end

  test "casting", %{complex: doc} do
    assert xpath(doc, ~x[/fantasy_content/league/league_id/text()]) == ~c"239541"
    assert xpath(doc, ~x[/fantasy_content/league/league_id/text()]s) == "239541"
    assert xpath(doc, ~x[/fantasy_content/league/league_id/text()]i) == 239_541
    assert xpath(doc, ~x[//total/text()]f) == 204.68
  end

  test "xml entities do not split strings" do
    assert xpath("<foo>hello&amp;world</foo>", ~x[/foo/text()]s) == "hello&world"
    assert xpath("<foo>hello&amp;world</foo>", ~x"name(.)"s) == "foo"
  end

  test "transform_by", %{complex: doc} do
    date_string_to_iso_week = fn str ->
      {_year, week} =
        str
        |> String.split("-", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
        |> :calendar.iso_week_number()

      week
    end

    parse_scoreboard = fn xpath_node ->
      xpath_node
      |> xmap(
        week: ~x"./week/text()"i,
        matchups: ~x"./matchups/@count"i
      )
    end

    result =
      doc
      |> xpath(
        ~x"//fantasy_content/league",
        iso_week: ~x"./start_date/text()"s |> transform_by(date_string_to_iso_week),
        scoreboard: ~x"./scoreboard" |> transform_by(parse_scoreboard)
      )

    assert result == %{iso_week: 36, scoreboard: %{week: 16, matchups: 4}}
  end

  test "namespace support: same prefix as in document", %{namespaces: doc} do
    result = doc |> xpath(~x"//ns1:delivery_type/text()"s)
    assert result == "courier"
  end

  test "namespace support: alternate prefixes", %{namespaces: doc} do
    result =
      parse(doc, namespace_conformant: true)
      |> xpath(
        ~x"/t:thing/s:delivery_type/text()"s
        |> add_namespace("s", "http://example.com/special")
        |> add_namespace("t", "http://example.com/thing")
      )

    assert result == "courier"
  end

  test "float sigil with integer and zero", %{float_sigil: doc} do
    assert doc |> xpath(~x"//product[@id=\"float\"]/price/text()"f) == 1.4
    assert doc |> xpath(~x"//product[@id=\"integer\"]/price/text()"f) == 3.0
    assert doc |> xpath(~x"//product[@id=\"zero\"]/price/text()"f) == 0.0
  end
end
