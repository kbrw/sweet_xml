defmodule SweetXmlStreamTest do
  # async disabled to allows to count ports
  use ExUnit.Case, async: false

  import SweetXml

  setup do
    simple = File.read!("./test/files/simple_stream.xml")
    complex_stream = File.stream!("./test/files/complex.xml")
    simple_stream = File.stream!("./test/files/simple_stream.xml")
    {:ok, [complex_stream: complex_stream, simple_stream: simple_stream, simple: simple]}
  end

  test "partial streaming closes the underlying stream", %{simple_stream: simple_stream} do
    nb_ports_before_stream = Enum.count(Port.list())
    simple_stream |> stream_tags(:span) |> Enum.take(2)
    # the stream is halted in another process, so wait a bit
    :timer.sleep(50)
    assert nb_ports_before_stream == Enum.count(Port.list())
  end

  test "full streaming closes the underlying stream, even if data after xml", %{
    simple_stream: simple_stream
  } do
    nb_ports_before_stream = Enum.count(Port.list())
    simple_stream |> stream_tags(:span) |> Enum.take(200)
    # the stream is halted in another process, so wait a bit
    :timer.sleep(50)
    assert nb_ports_before_stream == Enum.count(Port.list())
  end

  test "streaming tags", %{simple_stream: simple_stream} do
    result =
      simple_stream
      |> stream_tags([:li, :special_match_key], discard: [:li, :special_match_key])
      |> Stream.map(fn
        {_, doc} ->
          xpath(doc, ~x"./text()")
      end)
      |> Enum.to_list()

    assert result == [
             ~c"\n        First",
             ~c"Second\n      ",
             ~c"Third",
             ~c"Forth",
             ~c"first star"
           ]

    result =
      simple_stream
      |> stream_tags(:head)
      |> Stream.map(fn
        {_, doc} ->
          xpath(doc, ~x"./title/text()")
      end)
      |> Enum.to_list()

    assert result == [~c"Nested Head", ~c"XML Parsing"]
  end

  test "stream tags with xmerl_options", %{simple_stream: simple_stream} do
    result =
      simple_stream
      |> stream_tags([:li, :special_match_key],
        discard: [:li, :special_match_key],
        space: :normalize
      )
      |> Stream.map(fn
        {_, doc} ->
          xpath(doc, ~x"./text()")
      end)
      |> Enum.to_list()

    assert result == [~c" First", ~c"Second ", ~c"Third", ~c"Forth", ~c"first star"]
  end

  test "tag both given and discarded", %{simple_stream: simple_stream} do
    result =
      simple_stream
      |> stream_tags(:head, discard: [:head])
      |> Stream.map(fn
        {_, doc} ->
          xpath(doc, ~x".//title/text()")
      end)
      |> Enum.to_list()

    assert result == [~c"Nested Head", ~c"XML Parsing"]
  end

  test "streaming tags assertively", %{simple_stream: simple_stream} do
    result =
      simple_stream
      |> stream_tags!([:li, :special_match_key], discard: [:li, :special_match_key])
      |> Stream.map(fn {_, doc} -> xpath(doc, ~x"./text()") end)
      |> Enum.to_list()

    assert result == [
             ~c"\n        First",
             ~c"Second\n      ",
             ~c"Third",
             ~c"Forth",
             ~c"first star"
           ]

    result =
      simple_stream
      |> stream_tags!(:head)
      |> Stream.map(fn {_, doc} -> xpath(doc, ~x"./title/text()") end)
      |> Enum.to_list()

    assert result == [~c"Nested Head", ~c"XML Parsing"]
  end

  test "invalid xml" do
    assert_raise SweetXml.XmerlFatal, ":error_scanning_entity_ref", fn ->
      "test/files/invalid.xml"
      |> File.stream!()
      |> SweetXml.stream_tags!(:matchup, quiet: true)
      |> Stream.run()
    end
  end

  test "DTD error" do
    assert_raise SweetXml.DTDError, "DTD not allowed: lol1", fn ->
      "test/files/billion_laugh.xml"
      |> File.stream!()
      |> SweetXml.stream_tags!(:banana, dtd: :none, quiet: true)
      |> Stream.run()
    end
  end

  test "internal only" do
    assert_raise SweetXml.DTDError, "no external entity allowed", fn ->
      "test/files/xxe.xml"
      |> File.stream!()
      |> SweetXml.stream_tags!(:result, dtd: :internal_only)
      |> Stream.run()
    end
  end
end
