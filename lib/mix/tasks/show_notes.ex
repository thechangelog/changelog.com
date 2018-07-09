defmodule Mix.Tasks.Changelog.ShowNotes do
  use Mix.Task

  alias Changelog.{Episode, Github, Repo}

  @shortdoc "Pushes existing show notes to GitHub"

  def run(_) do
    Mix.Task.run("app.start")

    episodes =
      Episode.published
      |> Episode.newest_first
      |> Episode.preload_podcast
      |> Repo.all

    for episode <- episodes do
      source = Github.Source.new("show-notes", episode)
      case Github.Pusher.push(source, episode.notes) do
        {:ok, message} -> IO.puts("success: #{message}")
        {:error, message} -> IO.puts("error: #{message}")
      end
    end
  end
end
