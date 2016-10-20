defmodule Changelog.Stats do
  import Ecto
  import Ecto.Changeset

  alias Changelog.{Podcast, Repo, EpisodeStat}
  alias Changelog.Stats.{Analyzer, Parser}

  require Logger

  def process(date) do
    podcasts = Podcast.public |> Repo.all
    process(date, podcasts)
  end

  def process(date, podcast) when not is_list(podcast) do
    process(date, [podcast])
  end

  def process(date, podcasts) do
    podcasts
    |> Enum.map(fn(podcast) -> process_podcast(date, podcast) end)
    |> List.flatten
  end

  defp process_podcast(date, podcast) do
    fetch_files(date, podcast.slug)
    |> Parser.parse_files
    |> Enum.group_by(&(&1.episode))
    |> Enum.map(fn({slug, entries}) -> process_episode(date, podcast, slug, entries) end)
  end

  defp process_episode(date, podcast, slug, entries) do
    episode = assoc(podcast, :episodes) |> Repo.get_by!(slug: slug)

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
      {:ok, stat} -> stat
      {:error, _} -> log("Failed to insert/update episode: #{date} #{podcast.slug} #{slug}")
    end
    # update Podcast counts and Episode count
  end

  defp fetch_files(date, slug) do
    log("Fetching files for #{date} – #{slug}")
    file_dir = "/Users/jerod/src/changelog/dotcom/test/fixtures/logs/#{date}"
    {:ok, files} = File.ls(file_dir)
    files |> Enum.map(fn(file) -> "#{file_dir}/#{file}" end)
  end

  defp log(message) do
    Logger.info("Stats: #{message}")
  end
end
