defmodule Mix.Tasks.Changelog.Transcripts do
  use Mix.Task

  alias Changelog.{Episode, Github, Repo}

  @shortdoc "Refreshes all episode transcripts with latest from GitHub"

  def run(_) do
    Mix.Task.run("app.start")

    episodes =
      Episode.with_transcript()
      |> Episode.preload_podcast()
      |> Repo.all()

    Github.Puller.update("transcripts", episodes)
  end
end
