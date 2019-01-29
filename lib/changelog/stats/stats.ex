defmodule Changelog.Stats do
  import Ecto
  import Ecto.Changeset

  alias Changelog.{Podcast, Repo, Episode, EpisodeStat}
  alias Changelog.Stats.{Analyzer, Parser, S3}

  require Logger

  def process do
    date_range = Timex.Interval.new(from: Timex.shift(Timex.today, weeks: -1), until: Timex.today)

    for time <- date_range do
      Timex.to_date(time) |> process
    end
  end

  def process(date) do
    Logger.info("Stats: Start processing for #{date}")
    podcasts = Repo.all(Podcast.public)
    process(date, podcasts)
    Logger.info("Stats: Finished processing for #{date}")
  end

  def process(date, podcast) when not is_list(podcast), do: process(date, [podcast])

  def process(date, podcasts) do
    podcasts
    |> Enum.map(&Task.async(fn -> process_podcast(date, &1) end))
    |> Enum.flat_map(&Task.await(&1, 600_000)) # 10 minutes
  end

  defp process_podcast(date, podcast) do
    Logger.info("Stats: Processing #{podcast.name}")

    processed =
      S3.get_logs(date, podcast.slug)
      |> Parser.parse()
      |> Enum.group_by(&(&1.episode))
      |> Task.async_stream(fn({slug, entries}) -> process_episode(date, podcast, slug, entries) end)
      |> Enum.map(fn({:ok, stat}) -> stat end)

    Podcast.update_stat_counts(podcast)
    Logger.info("Stats: Finished Processing #{podcast.name}")

    processed
  end

  defp process_episode(date, podcast, slug, entries) do
    if episode = Repo.get_by(assoc(podcast, :episodes), slug: slug) do
      stat = case Repo.get_by(assoc(episode, :episode_stats), date: date) do
        nil -> %EpisodeStat{episode_id: episode.id, podcast_id: podcast.id, date: date, episode_bytes: episode.bytes}
        found -> found
      end

      stat = change(stat, %{
        total_bytes: Analyzer.bytes(entries),
        downloads: Analyzer.downloads(entries, stat.episode_bytes),
        uniques: Analyzer.uniques_count(entries),
        demographics: %{
          agents: Analyzer.downloads_by(entries, :agent, stat.episode_bytes),
          countries: Analyzer.downloads_by(entries, :country_code, stat.episode_bytes)
        }
      })

      case Repo.insert_or_update(stat) do
        {:ok, stat} ->
          Episode.update_stat_counts(episode)
          stat
        {:error, _} -> Logger.info("Stats: Failed to insert/update episode: #{date} #{podcast.slug} #{slug}")
      end
    else
      Logger.info("Stats: could not find #{podcast.name} with slug #{slug}")
    end
  end
end
