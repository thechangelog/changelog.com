defmodule Changelog.Transcripts.Updater do

  require Logger

  alias Changelog.{Episode, Regexp, Repo}
  alias Changelog.Transcripts.Source

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
    case Regex.named_captures(Regexp.transcript_slugs, item) do
      %{"podcast" => p, "episode" => e} ->
        Episode.published
        |> Episode.with_podcast_slug(p)
        |> Episode.with_slug(e)
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
