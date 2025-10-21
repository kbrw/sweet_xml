defmodule Issue71Test do
  use ExUnit.Case

  test "raise on reading /etc/passwd with dtd: :none" do
    sneaky_xml = File.read!("./test/files/xxe.xml")

    assert {:fatal, {{:error_fetching_DTD, {_, _}}, _file, _line, _col}} =
             catch_exit(SweetXml.parse(sneaky_xml, dtd: :none, quiet: true))
  end

  test "raise on reading /etc/passwd with dtd: :internal_only" do
    sneaky_xml = File.read!("./test/files/xxe.xml")

    assert {:fatal, {{:error_fetching_DTD, {_, _}}, _file, _line, _col}} =
             catch_exit(SweetXml.parse(sneaky_xml, dtd: :internal_only, quiet: true))
  end

  test "raise on reading /etc/passwd with dtd: [only: :banana]" do
    sneaky_xml = File.read!("./test/files/xxe.xml")

    assert_raise RuntimeError, fn ->
      SweetXml.parse(sneaky_xml, dtd: [only: :banana])
    end
  end

  test "raise on billion_laugh.xml with dtd: :none" do
    dangerous_xml = File.read!("./test/files/billion_laugh.xml")

    assert_raise RuntimeError, fn ->
      SweetXml.parse(dangerous_xml, dtd: :none)
    end
  end

  test "stream: raise on reading /etc/passwd with dtd: :none" do
    sneaky_xml = File.read!("./test/files/xxe.xml")

    _ = Process.flag(:trap_exit, true)

    pid =
      spawn_link(fn ->
        Stream.run(SweetXml.stream_tags(sneaky_xml, :banana, dtd: :none, quiet: true))
      end)

    assert_receive {:EXIT, ^pid, {:fatal, {{:error_fetching_DTD, {_, _}}, _file, _line, _col}}}
  end

  test "stream: raise on billion_laugh.xml with dtd: :none" do
    dangerous_xml = File.read!("./test/files/billion_laugh.xml")

    _ = Process.flag(:trap_exit, true)

    pid =
      spawn_link(fn ->
        Stream.run(SweetXml.stream_tags(dangerous_xml, :banana, dtd: :none, quiet: true))
      end)

    assert_receive {:EXIT, ^pid, {%RuntimeError{}, _stacktrace}}
  end
end
