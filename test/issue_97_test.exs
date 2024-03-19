defmodule Issue97Test do
  use ExUnit.Case

  test "stream_tags doesn't hang when used with stream take on empty xml" do
    parent = self()
    ref = make_ref()
    spawn_link fn ->
      "<feed></feed>"
      |> SweetXml.stream_tags(:feed)
      |> Stream.take(1)
      |> Enum.to_list()
      send(parent, {ref, :ok})
    end
    assert_receive {^ref, :ok}, :timer.seconds(1)
  end

  test "stream_tags! doesn't hang when used with stream take on empty xml" do
    parent = self()
    ref = make_ref()
    spawn_link fn ->
      "<feed></feed>"
      |> SweetXml.stream_tags!(:feed)
      |> Stream.take(1)
      |> Enum.to_list()
      send(parent, {ref, :ok})
    end
    assert_receive {^ref, :ok}, :timer.seconds(1)
  end
end
