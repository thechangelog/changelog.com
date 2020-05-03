defmodule Import2Alias.CallerTracer do
  def trace({:imported_function, meta, module, name, arity}, env) do
    Import2Alias.Server.record(env.file, meta[:line], meta[:column], module, name, arity)
    :ok
  end

  def trace(_event, _env) do
    :ok
  end
end

defmodule Import2Alias.Server do
  use Agent

  def start_link(module) do
    Agent.start_link(fn -> %{module: module, entries: %{}} end, name: __MODULE__)
  end

  def record(file, line, column, module, name, arity) do
    Agent.update(__MODULE__, fn state ->
      the_module = state.module

      if match?({^the_module, _, _}, {module, name, arity}) do
        entry = {line, column, module, name, arity}

        Map.update!(state, :entries, fn entries ->
          Map.update(entries, file, [entry], &[entry | &1])
        end)
      else
        state
      end
    end)
  end

  def entries() do
    Agent.get(__MODULE__, & &1.entries)
  end
end

defmodule Import2Alias do
  def import2alias(alias, entries) do
    for {file, entries} <- entries do
      if String.match?(file, ~r/description.ex/) do
        # IO.inspect(entries)

        # Stream the file contents into a map using line numbers as keys.
        file_map = File.stream!(file)
        |> Stream.with_index(1)
        |> Stream.map(fn {line, index} -> {index, line} end)
        |> Enum.into(%{})

        # Apply changes from each entry to the file_map.
        modified_lines = entries
        |> Enum.reduce(file_map, &(handle_entry(&1, &2, alias)))
        |> Enum.into([])
        |> List.keysort(0)
        |> Enum.map(&(elem(&1, 1)))
        |> Enum.join()

        File.write!(file, modified_lines)
      end

    end
  end

  defp handle_entry({line, column, module, function, arity} = entry, file_map, alias) do
    file_map
    |> Map.update!(line, &(update_string(&1, entry, alias)))
  end

  defp update_string(string, {line, column, module, function, arity} = entry, alias) do
    if column do
      String.replace(string, "#{function}", "#{inspect(alias)}.#{function}")
    else
      string
    end
  end

end
