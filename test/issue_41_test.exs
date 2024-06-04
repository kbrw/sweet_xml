defmodule Issue41Test do
  use ExUnit.Case, async: false

  test "warns on rules override: `dtd: :none`" do
    import ExUnit.CaptureLog

    rules =
      {:rules, fn _cntxt, _nm, _stt -> :undefined end, fn _cntxt, _nm, _vl, stt -> stt end, nil}

    # Warning ! Sensitive to async tests.
    assert capture_log(fn ->
             SweetXml.parse("<tag></tag>", [rules, dtd: :none])
           end) =~ "rules opt will be overridden because of the dtd option"
  end

  test "keeps our rules/1" do
    tid = :ets.new(nil, [])
    _ = SweetXml.parse("<tag></tag>", [{:rules, tid}])
    assert true = :ets.delete(tid)
  end

  test "keeps provided rules/3 with no strict dtd" do
    tid = :ets.new(nil, [])

    write_fun = fn cntxt, nm, vl, stt ->
      _ = :ets.insert(tid, {{cntxt, nm}, vl})
      stt
    end

    read_fun = fn cntxt, nm, _stt ->
      case :ets.lookup(tid, {cntxt, nm}) do
        [] -> :undefined
        [{_, vl}] -> vl
      end
    end

    rules = {:rules, read_fun, write_fun, tid}

    xml = ~S"""
    <!DOCTYPE foo [ <!ELEMENT foo ANY > ] >
    <tag></tag>
    """

    _ = SweetXml.parse(xml, [rules, dtd: :internal_only])
    residue = :ets.lookup(tid, {:elem_def, :foo})
    true = :ets.delete(tid)
    assert [_] = residue
  end
end
