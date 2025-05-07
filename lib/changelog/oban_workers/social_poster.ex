defmodule Changelog.ObanWorkers.SocialPoster do
  @moduledoc """
  This module defines the Oban worker for posting to social media about new episodes
  """
  use Oban.Worker

  alias Changelog.{Bsky, Episode, Post, Repo, Social, Zulip}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"episode_id" => episode_id}}) do
    episode = Episode |> Repo.get(episode_id) |> Episode.preload_all()

    if Changelog.Podcast.is_a_changelog_pod(episode.podcast) do
      Bsky.post(episode)
      Social.post(episode)
      Zulip.post(episode)
    end

    :ok
  end

  def perform(%Oban.Job{args: %{"post_id" => post_id}}) do
    post = Post |> Repo.get(post_id) |> Post.preload_all()

    Social.post(post)
    Zulip.post(post)

    :ok
  end

  def queue(episode = %Episode{}) do
    %{"episode_id" => episode.id} |> new() |> Oban.insert()
  end

  def queue(post = %Post{}) do
    %{"post_id" => post.id} |> new() |> Oban.insert()
  end
end
