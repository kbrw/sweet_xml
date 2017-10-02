defmodule SweetXmlTest do
  use ExUnit.Case, async: true
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
    {:ok, [simple: simple,
           complex: complex,
           readme: readme,
           complex_stream: complex_stream,
           simple_stream: simple_stream,
           namespaces: namespaces, float_sigil: float_sigil]}
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
    assert ~x"//header/text()" == %SweetXpath{path: '//header/text()', is_value: true, is_list: false, is_keyword: false, cast_to: false}
    assert ~x"//header/text()"e == %SweetXpath{path: '//header/text()', is_value: false, is_list: false, is_keyword: false, cast_to: false}
    assert ~x"//header/text()"l == %SweetXpath{path: '//header/text()', is_value: true, is_list: true, is_keyword: false, cast_to: false}
    assert ~x"//header/text()"k == %SweetXpath{path: '//header/text()', is_value: true, is_list: false, is_keyword: true, cast_to: false}
    assert ~x"//header/text()"s == %SweetXpath{path: '//header/text()', is_value: true, is_list: false, is_keyword: false, cast_to: :string}
    assert ~x"//header/text()"i == %SweetXpath{path: '//header/text()', is_value: true, is_list: false, is_keyword: false, cast_to: :integer}
    assert ~x"//header/text()"f == %SweetXpath{path: '//header/text()', is_value: true, is_list: false, is_keyword: false, cast_to: :float}
    assert ~x"//header/text()"el == %SweetXpath{path: '//header/text()', is_value: false, is_list: true, is_keyword: false, cast_to: false}
    assert ~x"//header/text()"le == %SweetXpath{path: '//header/text()', is_value: false, is_list: true, is_keyword: false, cast_to: false}
    assert ~x"//header/text()"sl == %SweetXpath{path: '//header/text()', is_value: true, is_list: true, is_keyword: false, cast_to: :string}
    assert ~x"//header/text()"ls == %SweetXpath{path: '//header/text()', is_value: true, is_list: true, is_keyword: false, cast_to: :string}
    assert ~x"//header/text()"il == %SweetXpath{path: '//header/text()', is_value: true, is_list: true, is_keyword: false, cast_to: :integer}
    assert ~x"//header/text()"li == %SweetXpath{path: '//header/text()', is_value: true, is_list: true, is_keyword: false, cast_to: :integer}
  end

  test "xpath with sweet_xpath as only argment", %{simple: doc} do
    result = doc |> xpath(~x"//header/text()"e)
    assert xmlText(result, :value) == 'Content Header'

    result = doc |> xpath(~x"//header/text()")
    assert result == 'Content Header'

    result = doc |> xpath(~x"//header/text()"s)
    assert result == "Content Header"

    result = doc |> xpath(~x"//span[contains(@class,'badge')][@data-attr='first-half']/text()"l)
    assert result == ['One', 'Two', 'Three', 'Four', 'Five']

    result = doc |> xpath(~x"//span[contains(@class,'badge')][@data-attr='first-half']/text()"ls)
    assert result == ["One", "Two", "Three", "Four", "Five"]

    result = doc |> xpath(~x"//span[contains(@class,'badge')][@data-attr='first-half']/text()"le)
    assert length(result) == 5
    assert result |> List.first |> xmlText(:value) == 'One'
  end

  test "xpath should return values for those entities that have values", %{simple: doc} do
    result = doc |> xpath(~x"//li/@class")
    assert result == 'first star'
    result = doc |> xpath(~x"//li/@data-index")
    assert result == '1'
  end

  test "xmap with single level", %{simple: doc} do
    result = doc |> xmap(
      header: ~x"//header/text()",
      badges: ~x"//span[contains(@class,'badge')][@data-attr='first-half']/text()"l
    )
    assert result == %{
      header: 'Content Header',
      badges: ['One', 'Two', 'Three', 'Four', 'Five']
    }
  end

  test "xmap with multiple level of spec", %{simple: doc} do
    result = doc |> xmap(
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
            %{class: 'first star', data_attr: nil, text: 'First'},
            %{class: 'second', data_attr: nil, text: 'Second'},
            %{class: 'third', data_attr: nil, text: 'Third'}
          ]
        }
      }
    }

    result = doc |> xpath(
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
          %{class: 'first star', data_attr: nil, text: 'First'},
          %{class: 'second', data_attr: nil, text: 'Second'},
          %{class: 'third', data_attr: nil, text: 'Third'}
        ]
      }
    }
  end

  test "xpath with multiple level of spec from stream", %{simple_stream: simple_stream} do
    result = simple_stream |> xmap(
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
            %{class: 'first star', data_attr: nil, text: '\n        First'},
            %{class: 'second', data_attr: nil, text: 'Second\n      '},
            %{class: 'third', data_attr: nil, text: 'Third'}
          ]
        }
      }
    }

    result = simple_stream |> xpath(
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
          %{class: 'first star', data_attr: nil, text: '\n        First'},
          %{class: 'second', data_attr: nil, text: 'Second\n      '},
          %{class: 'third', data_attr: nil, text: 'Third'}
        ]
      }
    }
  end
  test "reuse returned nodes", %{simple: doc} do
    result = doc
    |> xpath(~x"//li"l)
    |> Enum.map(&(&1 |> xpath(~x"./text()")))
    assert result == ['First', 'Second', 'Third', 'Forth']
  end

  test "complex parsing", %{complex: doc} do
    result = doc
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
          week: '16',
          winner: %{name: 'Asgardian Warlords', key: '273.l.239541.t.1'},
          loser: %{name: 'yourgoindown220', key: '273.l.239541.t.2'},
          teams: [
            %{name: 'Asgardian Warlords', key: '273.l.239541.t.1'},
            %{name: 'yourgoindown220', key: '273.l.239541.t.2'}
          ]
        },
        %{
          week: '16',
          winner: %{name: '187 she wrote', key: '273.l.239541.t.4'},
          loser: %{name: 'bleedgreen', key: '273.l.239541.t.6'},
          teams: [
            %{name: '187 she wrote', key: '273.l.239541.t.4'},
            %{name: 'bleedgreen', key: '273.l.239541.t.6'}
          ]
        },
        %{
          week: '16',
          winner: %{name: 'jo momma', key: '273.l.239541.t.9'},
          loser: %{name: 'Thunder Ducks', key: '273.l.239541.t.5'},
          teams: [
            %{name: 'Thunder Ducks', key: '273.l.239541.t.5'},
            %{name: 'jo momma', key: '273.l.239541.t.9'}
          ]
        },
        %{
          week: '16',
          winner: %{name: 'The Dude Abides', key: '273.l.239541.t.10'},
          loser: %{name: 'bingo_door', key: '273.l.239541.t.8'},
          teams: [
            %{name: 'bingo_door', key: '273.l.239541.t.8'},
            %{name: 'The Dude Abides', key: '273.l.239541.t.10'}
          ]
        }
      ]
    }
  end

  test "complex parsing and processing", %{complex: doc} do
    result = doc
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
    |> Enum.reduce(%{}, fn(matchup, stat) ->
      winner_name = matchup[:winner][:name]
      loser_name = matchup[:loser][:name]
      stat = Map.put_new(stat, winner_name, %{wins: 0, loses: 0})
      stat = Map.put_new(stat, loser_name, %{wins: 0, loses: 0})

      {_, stat} = get_and_update_in(stat, [winner_name, :wins], &{&1, &1 + 1})
      {_, stat} = get_and_update_in(stat, [loser_name, :loses], &{&1, &1 + 1})

      stat
    end)

    assert result == %{
      'Asgardian Warlords' => %{loses: 0, wins: 1},
      'yourgoindown220' => %{loses: 1, wins: 0},
      '187 she wrote' => %{loses: 0, wins: 1},
      'Thunder Ducks' => %{loses: 1, wins: 0},
      'The Dude Abides' => %{loses: 0, wins: 1},
      'jo momma' => %{loses: 0, wins: 1},
      'bleedgreen' => %{loses: 1, wins: 0},
      'bingo_door' => %{loses: 1, wins: 0}
    }
  end

  test "read me examples", %{simple: simple, readme: readme} do
    # get the name of the first match
    result = readme |> xpath(~x"//matchup/name/text()") # `x` marks sigil for (x)path
    assert result == 'Match One'

    # get the xml record of the name fo the first match
    result = readme |> xpath(~x"//matchup/name"e) # `e` is the modifier for (e)ntity
    assert elem(result, 0) == :xmlElement

    # get the full list of matchup name
    result = readme |> xpath(~x"//matchup/name/text()"l) # `l` stands for (l)ist
    assert result == ['Match One', 'Match Two', 'Match Three']

    # get a list of matchups with different map structure
    result = readme |> xpath(
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

    # get a list of matchups with keyword structure preserving order defined in spec
    result = readme |> xpath(
      ~x"//matchups/matchup"lk,
      name: ~x"./name/text()",
      winner: [
        ~x".//team/id[.=ancestor::matchup/@winner-id]/..",
        name: ~x"./name/text()"
      ]
    )
    assert result == [
      [name: 'Match One', winner: %{name: 'Team One'}],
      [name: 'Match Two', winner: %{name: 'Team Two'}],
      [name: 'Match Three', winner: %{name: 'Team One'}]
    ]

    # get a map with lots of nesting
    result = simple |> xmap(
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
          p: 'Neato €',
          first_list: [
            %{class: 'first star', data_attr: nil, text: 'First'},
            %{class: 'second', data_attr: nil, text: 'Second'},
            %{class: 'third', data_attr: nil, text: 'Third'}
          ],
          second_list: ['Forth']
        }
      },
      odd_badges_class_values: ['first badge odd', 'badge odd'],
      special_match: 'First'
    }
  end

  test "XPath functions that return xmlObj", %{simple: simple} do
    #Get name of root tag
    result = simple |> xpath(~x"name(.)")

    assert result == 'html'

    #Get number of li elements
    result = simple |> xpath(~x"count(//li)")

    assert result == 4

    #True and false
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
            id: ~x"./ID/text()"s]) == nil
  end

  test "casting", %{complex: doc} do
    assert xpath(doc, ~x[/fantasy_content/league/league_id/text()])  == '239541'
    assert xpath(doc, ~x[/fantasy_content/league/league_id/text()]s) == "239541"
    assert xpath(doc, ~x[/fantasy_content/league/league_id/text()]i) ==  239541
    assert xpath(doc, ~x[/fantasy_content/league/short_invitation_url/text()]) ==  nil
    assert xpath(doc, ~x[/fantasy_content/league/short_invitation_url/text()]o) ==  nil
    assert xpath(doc, ~x[/fantasy_content/league/short_invitation_url/text()]os) ==  nil
    assert xpath(doc, ~x[/fantasy_content/league/short_invitation_url/text()]oS) ==  nil
    assert xpath(doc, ~x[/fantasy_content/idontexist/text()]o) ==  nil
    assert xpath(doc, ~x[/fantasy_content/idontexist/text()]os) ==  nil
    assert xpath(doc, ~x[/fantasy_content/idontexist/text()]oS) ==  nil
    assert xpath(doc, ~x[//total/text()]f) ==  204.68
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
        |> List.to_tuple |> :calendar.iso_week_number
      week
    end

    parse_scoreboard = fn xpath_node ->
      xpath_node
      |> xmap(
        week: ~x"./week/text()"i,
        matchups: ~x"./matchups/@count"i
      )
    end

    result = doc
    |> xpath(
      ~x"//fantasy_content/league",
      iso_week: ~x"./start_date/text()"s |> transform_by(date_string_to_iso_week),
      scoreboard: ~x"./scoreboard" |> transform_by(parse_scoreboard),
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
      |> xpath(~x"/t:thing/s:delivery_type/text()"s
               |> add_namespace("s", "http://example.com/special")
               |> add_namespace("t", "http://example.com/thing"))

    assert result == "courier"
  end

  test "float sigil with integer and zero", %{float_sigil: doc} do
    assert doc |> xpath(~x"//product[@id=\"float\"]/price/text()"f)   == 1.4
    assert doc |> xpath(~x"//product[@id=\"integer\"]/price/text()"f) == 3.0
    assert doc |> xpath(~x"//product[@id=\"zero\"]/price/text()"f)    == 0.0
  end
end
