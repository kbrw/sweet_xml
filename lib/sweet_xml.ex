defmodule SweetXpath do
  defstruct path: ".", is_value: true, is_list: false
end

defmodule SweetXml do
  @moduledoc ~S"""
  `SweetXml` is a thin wrapper around `:xmerl`. It allows you to converts a
  string or xmlElement record as defined in `:xmerl` to an elixir value such
  as `map`, `list`, `char_list`, or any combination of these.

  `SweetXml` primarily exposes 3 functions

    * `SweetXml.xpath/2` - return a value based on the xpath expression
    * `SweetXml.xpath/3` - similar to above but allowing nesting of mapping
    * `SweetXml.xmap/2` - return a map with keywords mapped to values returned
      from xpath

  ## Examples

  Simple Xpath

      iex> import SweetXml
      iex> doc = "<h1><a>Some linked title</a></h1>"
      iex> doc |> xpath(~x"//a/text()")
      'Some linked title'

  Nested Mapping

      iex> import SweetXml
      iex> doc = "<body><header><p>Message</p><ul><li>One</li><li><a>Two</a></li></ul></header></body>"
      iex> doc |> xpath(~x"//header", message: ~x"./p/text()", a_in_li: ~x".//li/a/text()"l)
      %{a_in_li: ['Two'], message: 'Message'}

  For more examples please see the help for `SweetXml.xpath/2` and `SweetXml.xmap/2`

  ## The ~x Sigil

  Notice in the above examples, we used the expression `~x"//a/text()"` to
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

    * `~x"//some/path"el` - mix of the above

  Notice also in the examples section, we always import SweetXml first. This
  makes `x_sigil` available in the current scope. Without it, instead of using
  `~x`, you can do the following

      iex> doc = "<h1><a>Some linked title</a></h1>"
      iex> doc |> SweetXml.xpath(%SweetXpath{path: '//a/text()', is_value: true, is_list: false})
      'Some linked title'

  Note the use of char_list in the path definition.
  """

  require Record
  Record.defrecord :xmlDecl, Record.extract(:xmlDecl, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlNamespace, Record.extract(:xmlNamespace, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlNsNode, Record.extract(:xmlNsNode, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlComment, Record.extract(:xmlComment, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlPI, Record.extract(:xmlPI, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlDocument, Record.extract(:xmlDocument, from_lib: "xmerl/include/xmerl.hrl")

  @doc ~s"""
  `sigil_x/2` simply returns a `SweetXpath` struct, with modifiers converted to
  boolean fields

      iex> SweetXml.sigil_x("//some/path", 'e')
      %SweetXpath{path: '//some/path', is_value: false, is_list: false}

  or you can simply import and use the `~x` expression

      iex> import SweetXml
      iex> ~x"//some/path"e
      %SweetXpath{path: '//some/path', is_value: false, is_list: false}

  Valid modifiers are `e` and `l`. Below is the full explanation

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

    * `~x"//some/path"el` - mix of the above
  """
  def sigil_x(path, modifiers \\ '') do
    %SweetXpath{
      path: String.to_char_list(path),
      is_value: not ?e in modifiers,
      is_list: ?l in modifiers
    }
  end

  @doc """
  `doc` can be 

  - a byte list (iodata)
  - a binary
  - any enumerable of binaries (for instance `File.stream!/3` result)

  `options` are `xmerl` options described here [http://www.erlang.org/doc/man/xmerl_scan.html](http://www.erlang.org/doc/man/xmerl_scan.html),
  see [the erlang tutorial](http://www.erlang.org/doc/apps/xmerl/xmerl_examples.html) for usage.

  When `doc` is an enumerable, the `:cont_fun` option cannot be given.

  Return an `xmlElement` record
  """
  def parse(doc), do: parse(doc,[])
  def parse(doc,options) when is_binary(doc) do
    doc |> :erlang.binary_to_list |> parse(options)
  end
  def parse([c|_]=doc,options) when is_integer(c) do
    {parsed_doc, _} = :xmerl_scan.string(doc,options)
    parsed_doc
  end
  def parse(doc_enum,options) do
    {parsed_doc, _} = :xmerl_scan.string('', [continuation_opt(doc_enum)|options])
    parsed_doc
  end

  @doc ~S"""
  `xpath` allows you to query an xml document with xpath.

  The second argument to xpath is a `SweetXpath` struct. The optional third
  argument is a keyword list, such that the value of each keyword is also
  either a `SweetXpath` or a list with head being a `SweetXpath` and tail being
  another keyword list exactly like before. Please see examples below for better
  understanding.

  ## Examples

  Simple

      iex> import SweetXml
      iex> doc = "<h1><a>Some linked title</a></h1>"
      iex> doc |> xpath(~x"//a/text()")
      'Some linked title'

  With optional mapping

      iex> import SweetXml
      iex> doc = "<body><header><p>Message</p><ul><li>One</li><li><a>Two</a></li></ul></header></body>"
      iex> doc |> xpath(~x"//header", message: ~x"./p/text()", a_in_li: ~x".//li/a/text()"l)
      %{a_in_li: ['Two'], message: 'Message'}

  With optional mapping and nesting

      iex> import SweetXml
      iex> doc = "<body><header><p>Message</p><ul><li>One</li><li><a>Two</a></li></ul></header></body>"
      iex> doc
      ...> |> xpath(
      ...>      ~x"//header",
      ...>      ul: [
      ...>        ~x"./ul",
      ...>        a: ~x"./li/a/text()"
      ...>      ]
      ...>    )
      %{ul: %{a: 'Two'}}
  """
  def xpath(parent, spec) when not is_tuple(parent) do
    parent |> parse |> xpath(spec)
  end

  def xpath(parent, %SweetXpath{path: path, is_value: is_value, is_list: is_list}) do
    current_entities = :xmerl_xpath.string(path, parent)
    if is_list do
      if is_value do
        current_entities |> Enum.map &(_value(&1))
      else
        current_entities
      end
    else
      current_entity = List.first(current_entities)
      if is_value do
        _value current_entity
      else
        current_entity
      end
    end
  end

  def xpath(parent, sweet_xpath, subspec) do
    if sweet_xpath.is_list do
      current_entities = xpath(parent, sweet_xpath)
      Enum.map(current_entities, fn (entity) -> xmap(entity, subspec) end)
    else
      current_entity = xpath(parent, sweet_xpath)
      xmap(current_entity, subspec)
    end
  end

  @doc ~S"""
  `xmap` returns a mapping with each value being the result of `xpath`

  Just as `xpath`, you can nest the mapping structure. Please see `xpath` for
  more detail.

  ## Examples

  Simple

      iex> import SweetXml
      iex> doc = "<h1><a>Some linked title</a></h1>"
      iex> doc |> xmap(a: ~x"//a/text()")
      %{a: 'Some linked title'}

  With optional mapping

      iex> import SweetXml
      iex> doc = "<body><header><p>Message</p><ul><li>One</li><li><a>Two</a></li></ul></header></body>"
      iex> doc |> xmap(message: ~x"//p/text()", a_in_li: ~x".//li/a/text()"l)
      %{a_in_li: ['Two'], message: 'Message'}

  With optional mapping and nesting

      iex> import SweetXml
      iex> doc = "<body><header><p>Message</p><ul><li>One</li><li><a>Two</a></li></ul></header></body>"
      iex> doc
      ...> |> xmap(
      ...>      message: ~x"//p/text()",
      ...>      ul: [
      ...>        ~x"//ul",
      ...>        a: ~x"./li/a/text()"
      ...>      ]
      ...>    )
      %{message: 'Message', ul: %{a: 'Two'}}
  """
  def xmap(_, []) do
    %{}
  end

  def xmap(parent, [{label, spec} | tail]) when is_list(spec) do
    result = xmap(parent, tail)
    [sweet_xpath | subspec] = spec
    Dict.put result, label, xpath(parent, sweet_xpath, subspec)
  end

  def xmap(parent, [{label, sweet_xpath} | tail]) do
    result = xmap(parent, tail)
    Dict.put result, label, xpath(parent, sweet_xpath)
  end

  defp _value(entity) do
    cond do
      is_record? entity, :xmlText ->
        xmlText(entity, :value)
      is_record? entity, :xmlComment ->
        xmlComment(entity, :value)
      is_record? entity, :xmlPI ->
        xmlPI(entity, :value)
      is_record? entity, :xmlAttribute ->
        xmlAttribute(entity, :value)
      true ->
        entity
    end
  end

  defp is_record?(data, kind) do
    is_tuple(data) and tuple_size(data) > 0 and :erlang.element(1, data) == kind
  end

  defp continuation_opt(enum, waiter \\ nil) do
    {:continuation_fun,
     fn xcont,xexc,xstate->
        case :xmerl_scan.cont_state(xstate).({:cont,[]}) do
          {:suspended,bin,cont}-> 
            case waiter do
              nil -> :ok
              {parent,ref}->
                send(parent,{:wait,ref}); receive do {:continue,^ref}->:ok end
            end
            xcont.(bin,:xmerl_scan.cont_state(cont,xstate))
          {:done,_}->xexc.(xstate)
        end
     end,
     &Enumerable.reduce(split_by_whitespace(enum),&1,fn bin,_-> {:suspend,bin} end)}
   end

  defp split_by_whitespace(enum) do
    Stream.concat(enum,[:last]) |> Stream.transform("", fn 
      :last, prev->{[:erlang.binary_to_list(prev)],:done}
      bin, prev-> 
        bin = if (prev===""), do: bin, else: IO.iodata_to_binary([prev,bin])
        case split_last_whitespace(bin) do
          :white_bin->{[],bin}
          {head,tail}->{[:erlang.binary_to_list(head)],tail}
        end
    end)
  end

  defp split_last_whitespace(bin), do: split_last_whitespace(byte_size(bin)-1,bin)
  defp split_last_whitespace(0,_), do: :white_bin
  defp split_last_whitespace(size,bin) do
    case bin do
      <<_::binary-size(size),h>> <> tail when h==?\s or h==?\n or h==?\r or h==?\t-> 
        {head,_} = :erlang.split_binary(bin,size+1); {head,tail}
      _ -> split_last_whitespace(size-1,bin)
    end
  end
end
