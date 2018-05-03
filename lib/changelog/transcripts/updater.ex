defmodule Changelog.Transcripts.Updater do

  require Logger

  alias Changelog.{Episode, Podcast, Repo}
  alias Changelog.Transcripts.Source
  alias ChangelogWeb.PodcastView

  def update(items) when is_list(items) do
    for item <- items do
      item
      |> get_episode
      |> update_episode
    end
  end
  def update(item), do: update([item])

  defp get_episode(item = %Episode{}), do: item
  defp get_episode(item) do
    case String.split(item, "/") do
      [podcast_slug, filename] ->
        podcast_slug
        |> get_podcast_from_repo
        |> get_episode_from_repo(filename)
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

  defp update_episode(episode) when is_nil(episode), do: nil
  defp update_episode(episode) do
    transcript_url =
      episode
      |> Episode.preload_podcast
      |> Source.raw_url

    case HTTPoison.get!(transcript_url) do
      %{status_code: 200, body: text} -> Episode.update_transcript(episode, text)
      _else -> Logger.info("Transcripts: Failed to fetch #{transcript_url}")
    end
  end
end
