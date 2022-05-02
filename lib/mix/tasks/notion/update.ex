defmodule Mix.Tasks.Changelog.Notion.Update do
  use Mix.Task

  @shortdoc "Updates sponsorship reach counts in Notion"

  def run(_) do
    Mix.Task.run("app.start")
    Changelog.ObanWorkers.NotionUpdater.perform(%Oban.Job{})
  end
end
