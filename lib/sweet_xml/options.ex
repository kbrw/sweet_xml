defmodule SweetXml.Options do
  ### WARNING:
  # This is an internal api, use at your own risk.

  @moduledoc false

  # The dtd exception_module exists for backward compatibility.

  def handle_dtd(dtd_option, exception_module \\ RuntimeError)

  def handle_dtd(:all, _exception_module) do
    fn _ -> [] end
  end
  def handle_dtd(:none, exception_module) do
    fn ets ->
      handle_dtd(:internal_only, exception_module).(ets) ++ handle_dtd([only: []], exception_module).(ets)
    end
  end
  def handle_dtd(:internal_only, exception_module) do
    case exception_module do
      SweetXml.DTDError ->
        fn _ ->
          [fetch_fun: fn _, _ -> raise SweetXml.DTDError, message: "no external entity allowed" end]
        end
      _ ->
        fn _ ->
          [fetch_fun: fn _, _ -> {:error, "no external entity allowed"} end]
        end
    end
  end
  def handle_dtd([only: entity], exception_module) when is_atom(entity) do
    handle_dtd([only: [entity]], exception_module)
  end
  def handle_dtd([only: entities], exception_module) when is_list(entities) do
    fn ets ->
      read = fn
        context, name, state ->
          ets = :xmerl_scan.rules_state(state)
          case :ets.lookup(ets, {context, name}) do
            [] -> :undefined
            [{_, value}] -> value
          end
      end

        write = fn
          :entity = context, name, value, state ->
            _ = case name in entities do
              true ->
                ets = :xmerl_scan.rules_state(state)
                _ = case :ets.lookup(ets, {context, name}) do
                  [] -> :ets.insert(ets, {{context, name}, value})
                  _ -> :ok
                end
              false ->
                raise exception_module, message: "DTD not allowed: #{name}"
            end
            state

          context, name, value, state ->
            ets = :xmerl_scan.rules_state(state)
            _ = case :ets.lookup(ets, {context, name}) do
              [] -> :ets.insert(ets, {{context, name}, value})
              _ -> :ok
            end
            state
        end

      [{:rules, read, write, ets}]
    end
  end

  # This is kind of hard to follow :/
  # Basically, when we are not given any :rules option, then we do whatever.
  # When we are given a simple :rules/1 option, we assume it is an ets table, and we reuse it for the DTDs handling.
  # When we are given a :rules/3 option with function callbacks, we create our own table,
  # we set up the DTD handling opts, and then we check what is our expected behavior.
  # If we actually use the newly created ets (therefore creating a new :rules/3 option),
  # then we simply discard the user's option.
  # If we don't, we keep what the user gave us.
  # In both case, we add a rules/1 option because if we don't xmerl will do it.
  def set_up(opts, dtd_exception_module) do
    dtd_arg = :proplists.get_value(:dtd, opts, :all)
    opts = :proplists.delete(:dtd, opts)

    ret = {_opts, _do_after} = case :proplists.split(opts, [:rules]) do
      {[[]], opts} ->
        ets = :ets.new(nil, [:public])
        opts = opts ++ SweetXml.Options.handle_dtd(dtd_arg, dtd_exception_module).(ets) ++ [rules: ets]
        {opts, {:cleanup, ets}}

      # The only time we don't add a :rules/1
      {[[{:rules, ets}] = rules], opts} ->
        opts = rules ++ opts ++ SweetXml.Options.handle_dtd(dtd_arg, dtd_exception_module).(ets)
        {opts, :not_ours}

      {[[{:rules, _read_fun, _write_fun, _ets}] = rules], opts} ->
        ets = :ets.new(nil, [:public])
        dtd_opts = SweetXml.Options.handle_dtd(dtd_arg, dtd_exception_module).(ets)
        # If we don't use the `:rules/3` option for the DTDs, then we can keep the original one.
        case :proplists.split(dtd_opts, [:rules]) do
          {[[]], _opts} ->
            opts = opts ++ dtd_opts ++ rules ++ [rules: ets]
            {opts, {:cleanup, ets}}

          {[[_]], _opts} ->
            require Logger
            _ = Logger.warning("rules opt will be overridden because of the dtd option")
            opts = opts ++ dtd_opts ++ [rules: ets]
            {opts, {:cleanup, ets}}
        end
    end

    ret
  end

  def clean_up(:not_ours), do: :ok
  def clean_up({:cleanup, ets}), do: (:ets.delete(ets) ; :ok)
end
