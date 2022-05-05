# Empty
xml = '''
<gen><peach>melba</peach></gen>
'''
xpath = ~C[/gen/banana/split]
xpath_empty = {xml, xpath}

# Scalar
xml = '''
<gen><banana xmlns:split="dessert">split</banana></gen>
'''
xpath = ~C[count(/gen/banana)]
xpath_scalar = {xml, xpath}

# singleton(xmlText)
xml = '''
<gen><text>some text</text></gen>
'''
xpath = ~C[/gen/text/text()]
xpath_singleton_extractable = {xml, xpath}

# list(xmlText)
xml = '''
<gen><text>some text</text><text>some other text</text></gen>
'''
xpath = ~C[/gen/text/text()]
xpath_list_extractable = {xml, xpath}

# singleton(xmlText) int
xml = '''
<gen><text>4321</text></gen>
'''
xpath = ~C[/gen/text/text()]
xpath_singleton_extractable_int = {xml, xpath}

# list(xmlText) int
xml = '''
<gen><text>1234</text><text>4256</text></gen>
'''
xpath = ~C[/gen/text/text()]
xpath_list_extractable_int = {xml, xpath}

# singleton(xmlText) float
xml = '''
<gen><text>0.9</text></gen>
'''
xpath = ~C[/gen/text/text()]
xpath_singleton_extractable_float = {xml, xpath}

# list(xmlText) float
xml = '''
<gen><text>0.9</text><text>1.1</text></gen>
'''
xpath = ~C[/gen/text/text()]
xpath_list_extractable_float = {xml, xpath}

# list(xmlText) mixed number
xml = '''
<gen><text>4290</text><text>1.1</text></gen>
'''
xpath = ~C[/gen/text/text()]
xpath_list_extractable_mixed_number = {xml, xpath}

# xmlPI (extractable)
xml = '''
<gen><?banana split?></gen>
'''
xpath = ~C[/gen/processing-instruction('banana')]
{doc, []} = :xmerl_scan.string(xml)
_ret = :xmerl_xpath.string(xpath, doc)
# IO.inspect(ret, label: "singleton(xmlPI)")

# xmlNsNode (not extractable)
xml = '''
<gen><banana xmlns:split="dessert">split</banana></gen>
'''
xpath = ~C[/gen/banana/namespace::split]
xpath_singleton_not_extractable = {xml, xpath}

# list xmlNsNode (not extractable)
xml = '''
<gen><banana xmlns:split="dessert">split</banana><banana xmlns:split="dessert bis">split</banana></gen>
'''
xpath = ~C[/gen/banana/namespace::split]
xpath_list_not_extractable = {xml, xpath}

# import SweetXml
# xpath(~S[<gen><banana xmlns:split="dessert">split</banana></gen>], ~x[/gen/banana/namespace::split]) |> IO.inspect(label: "sweet_xml")

is_list = [true, false]
is_value = [true, false]
is_optional = [true, false]
cast_to = [:string, :soft_string, :integer, :soft_integer, :float, :soft_float, false]
xpaths = [
  xpath_empty,
  xpath_scalar,
  xpath_singleton_extractable,
  xpath_list_extractable,
  xpath_singleton_extractable_int,
  xpath_list_extractable_int,
  xpath_singleton_extractable_float,
  xpath_list_extractable_float,
  xpath_list_extractable_mixed_number,
  xpath_singleton_not_extractable,
  xpath_list_not_extractable,
]

possibilities = for {xml, xpath} <- xpaths do
  {doc, _rest} = :xmerl_scan.string(xml)
  input = :xmerl_xpath.string(xpath, doc)
  input_type = case input do
    [] -> "empty"
    {:xmlObj, _, _} -> "scalar"
    [_] -> "singleton(element)"
    [_, _] -> "list(element)"
  end
  #code = """
  #xml = '''
  ##{xml}
  #'''
  #xpath = ~C[#{xpath}]
  #description = \"\"\"
  #`#{inspect(res)}`
  #\"\"\"
  #"""
  #_ = IO.puts(code <> "\n")


  doc = SweetXml.parse(xml)
  for is_list <- is_list, is_value <- is_value, is_optional <- is_optional, cast_to <- cast_to do
    x = %SweetXpath{path: xpath, is_list: is_list, is_value: is_value, is_optional: is_optional, cast_to: cast_to}
    {res, type} = try do
      res = SweetXml.xpath(doc, x)
      type = case res do
        [] -> "empty(list)"

        i when is_integer(i) -> "int"
        t when is_tuple(t) -> "element"
        f when is_float(f) -> "float"
        s when is_binary(s) -> "string"
        nil -> "nil"

        [t1] when is_tuple(t1) -> "list(element)"
        [f1] when is_float(f1) -> "list(float)"
        [i1] when is_integer(i1) -> "list(int)"
        [s1] when is_binary(s1) -> "list(string)"
        [nil] -> "list(nil)"
        [l1] when is_list(l1) -> "list(charlist)"

        [t1, t2] when is_tuple(t1) and is_tuple(t2) -> "list(element)"
        [f1, f2] when is_float(f1) and is_float(f2) -> "list(float)"
        [i1, i2] when is_integer(i1) and is_integer(i2) -> "list(int)"
        [s1, s2] when is_binary(s1) and is_binary(s2) -> "list(string)"
        [nil, nil] -> "list(nil)"
        [l1, l2] when is_list(l1) and is_list(l2) -> "list(charlist)"

        [c1, c2, c3 | _] when is_integer(c1) and is_integer(c2) and is_integer(c3) -> "charlist"
      end
      {inspect(res), type}
    catch
      :error, {:case_clause, data} -> IO.inspect({data, xml, x}, label: "case clause error")
      _kind, _payload ->
        #require Logger
        #Logger.info("""
        #  xml = #{xml}
        #  xpath = #{xpath}
        #  to_case = #{cast_to}
        #  """)
        #Logger.error(Exception.format(kind, payload, __STACKTRACE__))
        {"", "error"}
    end

    modifiers = []
    modifiers = modifiers ++ if not is_value do [?e] else [] end
    modifiers = modifiers ++ if is_list do [?l] else [] end
    modifiers = modifiers ++ if is_optional do [?o] else [] end
    modifiers = modifiers ++ case cast_to do
      :string -> [?s]
      :soft_string -> [?S]
      :integer -> [?i]
      :soft_integer -> [?I]
      :float -> [?f]
      :soft_float -> [?F]
      false -> []
    end

    %{
      xml: to_string(xml),
      xpath: to_string(xpath),
      input: inspect(input),
      modifiers: modifiers,
      type: type,
      res: res,
      input_type: input_type,
    }

  end
end
|> Enum.concat()
|> Enum.group_by(fn x -> [x.input_type, x.modifiers, x.type] end)
|> Enum.sort_by(fn {k, _} -> k end)
|> Enum.flat_map(fn {_, xs} -> Enum.sort_by(xs, fn x -> x.modifiers end) end)
|> Enum.chunk_by(fn x -> {x.input, x.type, x.res} end)
|> Enum.map(fn xs ->
  merge = fn x, acc ->
    x = Map.update!(x, :modifiers, fn x -> [x] end)
    Map.merge(acc, x, fn
      :modifiers, ls, rs -> ls ++ rs
      _, v, v -> v
    end)
  end
    Enum.reduce(xs, %{}, merge)
end)
|> Enum.sort_by(fn x -> {x.input_type, x.type} end)
|> Enum.chunk_by(fn x -> {x.input_type, x.type} end)
|> Enum.map(fn xs ->
  merge = fn x, acc ->
    x = Map.update!(x, :xml, fn x -> [x] end)
    x = Map.update!(x, :xpath, fn x -> [x] end)
    x = Map.update!(x, :modifiers, fn x -> [x] end)
    x = Map.update!(x, :input, fn x -> [x] end)
    x = Map.update!(x, :res, fn x -> [x] end)
    Map.merge(acc, x, fn
      :xml, ls, rs -> ls ++ rs
      :xpath, ls, rs -> ls ++ rs
      :modifiers, ls, rs -> ls ++ rs
      :input, ls, rs -> ls ++ rs
      :res, ls, rs -> ls ++ rs
      _, v, v -> v
    end)
  end
    Enum.reduce(xs, %{}, merge)
end)

wrap = fn x -> "|#{x}|" end
headers = ["xml", "xpath", "input", "input_type", "modifiers", "type", "res"]

_ =
  headers
  |> Enum.join("|")
  |> wrap.()
  |> IO.puts()

_ =
  headers
  |> Enum.map_join("|", fn _ -> "-" end)
  |> wrap.()
  |> IO.puts()

Enum.each(possibilities, fn pos ->
  escape = fn
    "" -> ""
    x -> "`#{x}`"
  end
  o = fn g, h -> fn x -> x |> g.() |> h.() end end

  [
    pos.xml |> Enum.map_join("<br/>", (&String.trim/1) |> o.(escape)),
    pos.xpath |> Enum.map_join("<br/>", (&String.trim/1) |> o.(escape)),
    pos.input |> Enum.map_join("<br/>", (&String.trim/1) |> o.(escape)),
    pos.input_type,
    pos.modifiers |> Enum.map_join("<br/>", (&inspect/1) |> o.(escape)),
    pos.type,
    pos.res |> Enum.map_join("<br/>", (&String.trim/1) |> o.(escape)),
  ]
  |> Enum.join("|")
  |> wrap.()
  |> IO.puts()
end)
