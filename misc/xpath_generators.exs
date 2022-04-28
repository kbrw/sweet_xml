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
<gen><text>432</text></gen>
'''
xpath = ~C[/gen/text/text()]
xpath_singleton_extractable_int = {xml, xpath}

# list(xmlText) int
xml = '''
<gen><text>12</text><text>42</text></gen>
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
<gen><text>42</text><text>1.1</text></gen>
'''
xpath = ~C[/gen/text/text()]
xpath_list_extractable_mixed_number = {xml, xpath}

# xmlPI (extractable)
xml = '''
<gen><?banana split?></gen>
'''
xpath = ~C[/gen/processing-instruction('banana')]
{doc, []} = :xmerl_scan.string(xml)
ret = :xmerl_xpath.string(xpath, doc)
IO.inspect(ret, label: "singleton(xmlPI)")

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

import SweetXml
xpath(~S[<gen><banana xmlns:split="dessert">split</banana></gen>], ~x[/gen/banana/namespace::split]) |> IO.inspect(label: "sweet_xml")

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

for {xml, xpath} <- xpaths do
  doc = SweetXml.parse(xml)
  for is_list <- is_list, is_value <- is_value, is_optional <- is_optional, cast_to <- cast_to do
    x = %SweetXpath{path: xpath, is_list: is_list, is_value: is_value, is_optional: is_optional, cast_to: cast_to}
    type = try do
      SweetXml.xpath(doc, x)
      |> case do
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
    catch
      :error, {:case_clause, data} -> IO.inspect({data, xml, x}, label: "case clause error")
      kind, payload ->
        #require Logger
        #Logger.error(Exception.format(kind, payload, __STACKTRACE__))
        "error"
    end
  end
end
