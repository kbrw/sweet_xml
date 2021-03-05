defmodule Issue71Test do
  use ExUnit.Case

  test "raise on reading /etc/passwd with dtd: :none" do
    sneaky_xml = """
    <?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <!DOCTYPE foo [ <!ELEMENT foo ANY >
    <!ENTITY xxe SYSTEM \"file:///etc/passwd\" >]>
    <response><result>&xxe;</result></response>
    """

    assert {:fatal, {{:error_fetching_DTD, {_, _}}, _file, _line, _col}} =
      catch_exit(SweetXml.parse(sneaky_xml, dtd: :none, quiet: true))
  end

  test "raise on billion_laugh.xml with dtd: :none" do
    dangerous_xml = File.read!("./test/files/billion_laugh.xml")
    assert_raise RuntimeError, fn ->
      SweetXml.parse(dangerous_xml, dtd: :none)
    end
  end

  test "stream: raise on reading /etc/passwd with dtd: :none" do
    sneaky_xml = """
    <?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <!DOCTYPE foo [ <!ELEMENT foo ANY >
    <!ENTITY xxe SYSTEM \"file:///etc/passwd\" >]>
    <response><result>&xxe;</result></response>
    """

    _ = Process.flag(:trap_exit, true)
    pid = spawn_link(fn -> Stream.run(SweetXml.stream_tags(sneaky_xml, :banana, dtd: :none, quiet: true)) end)
    assert_receive {:EXIT, ^pid, {:fatal, {{:error_fetching_DTD, {_, _}}, _file, _line, _col}}}
  end

  test "stream: raise on billion_laugh.xml with dtd: :none" do
    dangerous_xml = File.read!("./test/files/billion_laugh.xml")

    _ = Process.flag(:trap_exit, true)
    pid = spawn_link(fn -> Stream.run(SweetXml.stream_tags(dangerous_xml, :banana, dtd: :none, quiet: true)) end)
    assert_receive {:EXIT, ^pid, {%RuntimeError{}, _stacktrace}}
  end
end
