defmodule SweetXml.Options do
  @moduledoc false

  def handle_dtd(:all) do
    fn _, _ -> [] end
  end
  def handle_dtd(:none) do
    fn ets, exception_module ->
      handle_dtd(:internal_only).(ets, exception_module) ++ handle_dtd(only: []).(ets, exception_module)
    end
  end
  def handle_dtd(:internal_only) do
    fn _, _ ->
      [fetch_fun: fn _, _ -> {:error, "no external entity allowed"} end]
    end
  end
  def handle_dtd(only: entity) when is_atom(entity) do
    handle_dtd(only: [entity])
  end
  def handle_dtd(only: entities) when is_list(entities) do
    fn ets, exception_module ->
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
