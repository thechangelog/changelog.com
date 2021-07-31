defmodule Mix.Tasks.Changelog.Slack do
  use Mix.Task

  @shortdoc "Retrieves list of Slack users and updates local Slack IDs"

  def run(_) do
    Mix.Task.run("app.start")
    Changelog.ObanWorkers.SlackImporter.perform(%Oban.Job{})
  end
end
