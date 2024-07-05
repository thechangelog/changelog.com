defmodule Changelog.ObanWorkers.NotesPusher do
  @moduledoc """
  This module defines the Oban worker for pushing episode notes to GitHub
  """
  use Oban.Worker

  alias Changelog.{Episode, Github, Repo}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"episode_id" => episode_id}}) do
    episode = Episode |> Repo.get(episode_id) |> Episode.preload_podcast()
    source = Github.Source.new("show-notes", episode)

    Github.Pusher.push(source, episode.notes)

    :ok
  end

  def queue(episode = %Episode{}) do
    %{"episode_id" => episode.id} |> new() |> Oban.insert()
  end
end
