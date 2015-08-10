defmodule SweetXmlStreamTest do
  use ExUnit.Case, async: false #async disabled to allows to count ports

  import SweetXml

  setup do
    simple = File.read!("./test/files/simple_stream.xml")
    complex_stream = File.stream!("./test/files/complex.xml")
    simple_stream = File.stream!("./test/files/simple_stream.xml")
    {:ok, [complex_stream: complex_stream, simple_stream: simple_stream, simple: simple]}
  end

  test "partial streaming closes the underlying stream", %{simple_stream: simple_stream} do
    nb_ports_before_stream = Enum.count(Port.list)
    simple_stream |> stream_tags(:span) |> Enum.take(2)
    :timer.sleep(50) # the stream is halted in another process, so wait a bit
    assert nb_ports_before_stream == Enum.count(Port.list)
  end

  test "full streaming closes the underlying stream, even if data after xml", %{simple_stream: simple_stream} do
    nb_ports_before_stream = Enum.count(Port.list)
    simple_stream |> stream_tags(:span) |> Enum.take(200)
    :timer.sleep(50) # the stream is halted in another process, so wait a bit
    assert nb_ports_before_stream == Enum.count(Port.list)
  end

  test "streaming tags", %{simple_stream: simple_stream} do
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

  test "stream tags with xmerl_options", %{simple_stream: simple_stream} do
    result = simple_stream
    |> stream_tags([:li, :special_match_key], discard: [:li, :special_match_key], space: :normalize)
    |> Stream.map(fn
        {_, doc} ->
          xpath(doc, ~x"./text()")
      end)
    |> Enum.to_list

    assert result == [' First', 'Second ', 'Third', 'Forth', 'first star']
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
