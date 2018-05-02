defmodule Changelog.Github.Updater do

  require Logger

  alias Changelog.{Episode, Github, Regexp, Repo}

  def update(items, type) when is_list(items) do
    for item <- items do
      item
      |> get_episode
      |> update_episode(type)
    end
  end
  def update(item, type), do: update([item], type)

  defp get_episode(episode = %Episode{}), do: episode
  defp get_episode(filename) do
    case extract_podcast_and_episode_slugs_from(filename) do
      %{"podcast" => p, "episode" => e} ->
        Episode.published
        |> Episode.with_podcast_slug(p)
        |> Episode.with_slug(e)
        |> Repo.one
      nil -> nil
    end
  end

  defp extract_podcast_and_episode_slugs_from(filename) do
    Regex.named_captures(Regexp.github_filename_slugs, filename)
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
