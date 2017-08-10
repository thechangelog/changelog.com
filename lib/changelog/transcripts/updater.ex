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

  defp get_episode(item) when is_map(item), do: item
  defp get_episode(item) when is_binary(item) do
    %{"podcast" => p_slug, "episode" => e_slug} = Regex.named_captures(Regexp.transcript_slugs, item)

    Episode.published
    |> Episode.with_podcast_slug(p_slug)
    |> Episode.with_slug(e_slug)
    |> Repo.one
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
