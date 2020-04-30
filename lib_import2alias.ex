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
      lines = File.read!(file) |> String.split("\n")

      lines =
        Enum.reduce(entries, lines, fn entry, acc ->
          {line, column, module, name, arity} = entry

          List.update_at(acc, line - 1, fn string ->
            if column do
              # the column in imported calls in captures is reported at "&" character
              column = if String.at(string, column - 1) == "&", do: column + 1, else: column            
              pre = String.slice(string, 0, column - 1)
              offset = column - 1 + String.length("#{name}")
              post = String.slice(string, offset, String.length(string))
              pre <> "#{inspect(alias)}.#{name}" <> post
            else
              file = Path.relative_to(file, File.cwd!())

              IO.puts(
                "skipping #{file}:#{line} #{inspect(module)}.#{name}/#{arity}: no column info"
              )

              string
            end
          end)
        end)

      File.write!(file, Enum.join(lines, "\n"))
    end
  end
end