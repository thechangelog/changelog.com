defmodule Mix.Tasks.Changelog.UserAgents do
  use Mix.Task

  @shortdoc "Downloads latest data from https://github.com/opawg/user-agents-v2"

  def run(_) do
    Mix.Task.run("app.start")

    for file <- ~w(bots apps libraries browsers) do
      src = "https://raw.githubusercontent.com/opawg/user-agents-v2/master/src/#{file}.json"
      dest = "./priv/repo/agents/#{file}.json"

      case Changelog.HTTP.get(src) do
        {:ok, response} -> File.write(dest, response.body)
        {:error, error} -> IO.puts "Error on #{file}: #{error}"
      end
    end
  end
end
