defmodule Mix.Tasks.Changelog.Stats.Missing do
  use Mix.Task

  alias Changelog.{EpisodeStat, Podcast, Repo}

  @shortdoc "Prints dates with no episode stats for each active podcast"

  def run(_args) do
    Mix.Task.run "app.start"

    for podcast <- Repo.all(active_podcasts_query()) do
      if first_stat = Repo.one(first_stat_query(podcast)) do
          IO.puts "#{podcast.name}'s first stat was on #{first_stat.date}"

          for date <- day_interval(first_stat.date)  do
            if !Repo.exists?(stat_on_date_query(podcast, date)) do
              IO.puts "\tNo stats on ~D[#{Timex.to_date(date)}]"
            end
          end
      end
    end
  end

  defp day_interval(date) do
    Timex.Interval.new(from: date, until: Timex.today(), left_open: true)
  end

  defp active_podcasts_query do
    Podcast |> Podcast.active() |> Podcast.by_position()
  end

  defp first_stat_query(podcast) do
    podcast
    |> Ecto.assoc(:episode_stats)
    |> EpisodeStat.newest_last(:date)
    |> EpisodeStat.limit(1)
  end

  defp stat_on_date_query(podcast, date) do
    podcast
    |> Ecto.assoc(:episode_stats)
    |> EpisodeStat.on_date(date)
  end
end
