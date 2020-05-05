defmodule Mix.Tasks.Import2alias do
  use Mix.Task

  @impl true
  def run(args) do
    unless Version.match?(System.version(), ">= 1.10.0-rc") do
      Mix.raise("Elixir v1.10+ is required!")
    end

    case args do
      [module, alias] ->
        run(Module.concat([module]), Module.concat([alias]))

      _ ->
        Mix.raise("Usage: elixir -r lib_import2alias.ex -S mix import2alias MODULE ALIAS")
    end
  end

  defp run(module, alias) do
    {:ok, _} = Import2Alias.Server.start_link(module)
    Code.compiler_options(parser_options: [columns: true])
    Mix.Task.rerun("compile.elixir", ["--force", "--tracer", "Import2Alias.CallerTracer"])
    entries = Import2Alias.Server.entries()
    Import2Alias.import2alias(alias, entries)
  end
end
