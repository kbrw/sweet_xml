defmodule SweetXmlStreamTest do
  use ExUnit.Case, async: true

  import SweetXml

  setup do
    simple = File.read!("./test/files/simple_stream.xml")
    complex_stream = File.stream!("./test/files/complex.xml")
    simple_stream = File.stream!("./test/files/simple_stream.xml")
    {:ok, [complex_stream: complex_stream, simple_stream: simple_stream, simple: simple]}
  end

  test "streaming tags", %{simple_stream: simple_stream, simple: simple} do
    result = simple_stream
    |> stream_tags([:li, :special_match_key], discard: [:li, :special_match_key])
    |> Stream.map(fn
        {_, doc} ->
          xpath(doc, ~x"./text()")
      end)
    |> Enum.to_list

    assert result == ['\n        First', 'Second\n      ', 'Third', 'Forth', 'first star']

    result = simple_stream
    |> stream_tags(:head)
    |> Stream.map(fn
        {_, doc} ->
          xpath(doc, ~x"./title/text()")
      end)
    |> Enum.to_list

    assert result == ['Nested Head', 'XML Parsing']
  end

  test "tag both given and discarded", %{simple_stream: simple_stream} do
    result = simple_stream
    |> stream_tags(:head, discard: [:head])
    |> Stream.map(fn
        {_, doc} ->
          xpath(doc, ~x".//title/text()")
      end)
    |> Enum.to_list

    assert result == ['Nested Head', 'XML Parsing']
  end

end
