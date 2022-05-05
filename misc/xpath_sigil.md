modifiers:
?e -> not :is_value
?l -> :is_list
?k -> :is_keyword
?o -> :is_optional
?s -> cast_to: :string
  ?S -> cast_to: :soft_string
    ?i -> cast_to: :integer
      ?I -> cast_to: :soft_integer
        ?f -> cast_to: :float
          ?F -> cast_to: :soft_float
          otherwise -> cast_to: false

selects a unique cast target in the above order

type Extractable =  xmlText | xmlComment | xmlPI | xmlAttribute | xmlObj

:xmerl_xpath.string/3 = [],                           is_list: true, is_value: true, cast_to: _, is_optional: _ -> []
:xmerl_xpath.string/3 = list(_),                      is_list: true, is_value: true, cast_to: false, is_optional: _ -> list(_)
:xmerl_xpath.string/3 = list(Extractable),            is_list: true, is_value: true, cast_to: cast, is_optional: is_opt? -> list(cast(Extractable.value))
:xmerl_xpath.string/3 = list(not Extractable),        is_list: true, is_value: true, cast_to: :string, is_optional: false -> error!
:xmerl_xpath.string/3 = list(not Extractable),        is_list: true, is_value: true, cast_to: :soft_string, is_optional: false -> list("")
:xmerl_xpath.string/3 = list(not Extractable),        is_list: true, is_value: true, cast_to: :soft_string, is_optional: true -> list(nil)
:xmerl_xpath.string/3 = list(not Extractable),        is_list: true, is_value: true, cast_to: _, is_optional: is_opt? -> [_]
|> Enum.map(&_value/1)
|> Enum.map(to_cast(cast,is_opt?))
:xmerl_xpath.string/3 = [_, _ | _], is_list: true, is_value: true, cast_to: to_cast, is_optional: is_opt? -> [_, _ | _]
|> Enum.map(&_value/1)
|> Enum.map(to_cast(cast,is_opt?))
:xmerl_xpath.string/3 = xmlObj,     is_list: true, is_value: true, cast_to: to_cast, is_optional: is_opt? -> [xmlObj]
|> Enum.map(&_value/1)
|> Enum.map(to_cast(cast,is_opt?))


:xmerl_xpath.string/3 = list(),     is_list: true, is_value: false -> list()
:xmerl_xpath.string/3 = xmlObj,     is_list: true, is_value: false -> [xmlObj]


 is_list: false, is_value: true, cast_to: :string, is_optional: is_opt?
 :xmerl_xpath.string(path, parent, [namespace: namespaces])
 |> List.wrap()
 |> Enum.map(&_value/1)
 |> Enum.map(&to_string/1)
 |> Enum.join()

 is_list: false, is_value: true, cast_to: :soft_string, is_optional: is_opt?
 :xmerl_xpath.string(path, parent, [namespace: namespaces])
 |> List.wrap()
 |> Enum.map(&_value/1)
 |> Enum.map(fn value ->
   if String.Chars.impl_for(value) do
     to_string(value)
   else
     if is_opt?, do: nil, else: ""
   end
 end)
 |> Enum.join()

:xmerl_xpath.string/3 = [],       is_list: false, is_value: true, cast_to: cast, is_optional: is_opt? -> nil
:xmerl_xpath.string/3 = [x | _],  is_list: false, is_value: true, cast_to: cast, is_optional: is_opt?
:xmerl_xpath.string/3 = xmlObj,   is_list: false, is_value: true, cast_to: cast, is_optional: is_opt? -> to_cast(_value(xmlObj), cast, is_opt?)

ret = :xmerl_xpath.string(path, parent, [namespace: namespaces])
if is_record?(ret, :xmlObj) do
  ret
else
  List.first(ret)
end
|> _value()
|> to_cast(cast, is_opt?)


:xmerl_xpath.string/3 = [], is_list: false, is_value: false -> nil
:xmerl_xpath.string/3 = [x | _], is_list: false, is_value: false -> x
:xmerl_xpath.string/3 = xmlObj, is_list: false, is_value: false -> xmlObj


# TODO: Document the nesting of xpath subspec (behave differently with the modifier ?l)


empty = []
list(x, xs) = [x | xs]
singleton(x) = list(x, empty)

extractable = xml record _with extractable value (xmlText | xmlComment | xmlPI | xmlAttribute | xmlObj)
not_extractable = xml record without extractable
mixed = extractable | not_extractable

:xmerl_xpath.string/3 = empty
:xmerl_xpath.string/3 = singleton(xmlObj)
