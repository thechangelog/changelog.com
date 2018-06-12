defmodule Mix.Tasks.Changelog.ShowNotes do
  use Mix.Task

  alias Changelog.{Episode, Github, Repo}

  @shortdoc "Pushes existing show notes to GitHub"

  def run(_) do
    Mix.Task.run("app.start")

    episodes =
      Episode.published
      |> Episode.preload_podcast
      |> Repo.all

    for episode <- episodes do
      source = Github.Source.new("show-notes", episode)
      case Github.Pusher.push(source, episode.notes) do
        {:ok, %{status_code: 200}} -> IO.puts("updated #{episode.title}")
        {:ok, %{status_code: 201}} -> IO.puts("created #{episode.title}")
        {:ok, %{status_code: code, body: %{"message" => message}}} -> IO.puts("error: #{code} - #{message}")
        {:error, message} -> IO.puts("error: #{message}")
      end
    end
  end
end
