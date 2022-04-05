defmodule SweetXml.Options do
  ### WARNING:
  # This is an intenal api, use at your own risk.

  @moduledoc false

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
end
