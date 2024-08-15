defmodule Changelog.ObanWorkers.EpisodeStatsProcessor do
  use Oban.Worker, queue: :scheduled, unique: [period: 600]

  import Ecto.Query, only: [select: 3]

  alias Changelog.{Cache, Podcast, Repo, Episode, EpisodeStat}
  alias Changelog.Stats.{Analyzer, Parser, S3}
  alias Ecto.Changeset

  require Logger

  @impl Oban.Worker
  def timeout(_job), do: 600_000

  @impl Oban.Worker
  def perform(%Job{args: %{"date" => date, "podcast_id" => podcast_id}}) do
    date = Date.from_iso8601!(date)
    podcast = Repo.get!(Podcast, podcast_id)

    processed =
      podcast.slug
      |> S3.get_logs(date)
      |> Parser.parse()
      |> Enum.group_by(& &1.episode)
      |> Enum.map(fn {slug, entries} -> process_episode(date, podcast, slug, entries) end)

    Podcast.update_stat_counts(podcast)

    {:ok, processed}
  end

  @doc """
  This form will process all episodes for the current date and requeue itself
  if the given date is in the past.
  """
  def perform(%Job{args: %{"date" => date}}) do
    date = Date.from_iso8601!(date)
    Logger.info "Called for #{date}"

    podcast_ids =
      Podcast.public()
      |> select([p], p.id)
      |> Repo.all()

    for(id <- podcast_ids) do
      Logger.info "Performing for #{date}: #{id}"
      perform(%Oban.Job{args: %{"date" => Date.to_string(date), "podcast_id" => id}})
    end

    if is_in_past?(date) do
      Logger.info "new job"
      new(%{date: Date.add(date, 1)}) |> Oban.insert()
    end

    :ok
  end

  def perform(_job) do
    today = Date.utc_today()
    range = Date.range(Date.add(today, -2), Date.add(today, -1))

    podcast_ids =
      Podcast.public()
      |> select([p], p.id)
      |> Repo.all()

    jobs =
      for(date <- range, pid <- podcast_ids, do: %{date: date, podcast_id: pid})
      |> Enum.map(&new/1)
      |> Oban.insert_all()

    Cache.delete_prefix("stats-")

    {:ok, jobs}
  end

  defp is_in_past?(date), do: Timex.compare(date, Date.utc_today()) < 0

  defp process_episode(date, podcast, slug, entries) do
    if episode = Repo.get_by(Ecto.assoc(podcast, :episodes), slug: slug) do
      stat =
        case Repo.get_by(Ecto.assoc(episode, :episode_stats), date: date) do
          nil ->
            %EpisodeStat{
              episode_id: episode.id,
              podcast_id: podcast.id,
              date: date,
              episode_bytes: episode.audio_bytes
            }

          found ->
            found
        end

      stat =
        Changeset.change(stat, %{
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
          Episode.update_email_stats(episode)
          stat

        {:error, _} ->
          Logger.info("Stats: Failed to insert/update episode: #{date} #{podcast.slug} #{slug}")
      end
    else
      Logger.info("Stats: could not find #{podcast.name} with slug #{slug}")
    end
  end
end
