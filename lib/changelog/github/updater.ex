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

  defp get_episode(item = %Episode{}), do: item
  defp get_episode(item) do
    case Regex.named_captures(Regexp.transcript_slugs, item) do
      %{"podcast" => p, "episode" => e} ->
        Episode.published
        |> Episode.with_podcast_slug(p)
        |> Episode.with_slug(e)
        |> Repo.one
      nil -> nil
    end
  end

  defp update_episode(episode, _type) when is_nil(episode), do: nil
  defp update_episode(episode, type) do
    episode = Episode.preload_podcast(episode)
    raw_url = Github.Source.raw_url(type, episode)

    case HTTPoison.get!(raw_url) do
      %{status_code: 200, body: text} -> update_function(type, episode, text)
      _else -> Logger.info("#{String.capitalize(type)}: Failed to fetch #{raw_url}")
    end
  end

  defp update_function("transcripts", episode, text) do
    Episode.update_transcript(episode, text)
  end

  defp update_function("show-notes", episode, text) do
    Episode.update_notes(episode, text)
  end
end
