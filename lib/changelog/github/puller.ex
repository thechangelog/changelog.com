defmodule Changelog.Github.Puller do

  require Logger

  alias Changelog.{Cache, Episode, Github, Podcast, Repo}
  alias ChangelogWeb.PodcastView

  def update(type, items) when is_list(items) do
    for item <- items do
      item
      |> get_episode
      |> update_episode(type)
      |> Cache.delete
    end
  end
  def update(type, item), do: update(type, [item])

  defp get_episode(episode = %Episode{}), do: episode
  defp get_episode(filename) do
    case String.split(filename, "/") do
      [podcast_slug, episode_section] ->
        podcast_slug
        |> get_podcast_from_repo
        |> get_episode_from_repo(episode_section)
      _else -> nil
    end
  end

  defp get_podcast_from_repo(slug), do: Repo.get_by(Podcast, slug: slug)

  defp get_episode_from_repo(nil, _filename), do: nil
  defp get_episode_from_repo(podcast, filename) do
    podcast_name = PodcastView.dasherized_name(podcast)
    case Regex.named_captures(~r/#{podcast_name}-(?<episode>.*?)\.md/, filename) do
      %{"episode" => episode_slug} ->
        Episode.published
        |> Episode.with_podcast_slug(podcast.slug)
        |> Episode.with_slug(episode_slug)
        |> Repo.one
      nil -> nil
    end
  end

  defp update_episode(episode, _type) when is_nil(episode), do: nil
  defp update_episode(episode, type) do
    episode = Episode.preload_podcast(episode)
    source = Github.Source.new(type, episode)

    case HTTPoison.get!(source.raw_url) do
      %{status_code: 200, body: text} -> update_function(type, episode, text)
      _else -> Logger.info("#{String.capitalize(type)}: Failed to fetch #{source.raw_url}")
    end
  end

  defp update_function("transcripts", episode, text) do
    Episode.update_transcript(episode, text)
  end

  defp update_function("show-notes", episode, text) do
    Episode.update_notes(episode, text)
  end
end
