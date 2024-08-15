defmodule Mix.Tasks.Changelog.Stats.Process do
  use Mix.Task

  alias Changelog.{Podcast, Repo}
  alias Changelog.ObanWorkers.EpisodeStatsProcessor

  @shortdoc "Processes stats for given date, or all missing dates"

  def run(args) when is_nil(args), do: run([])

  def run(args) do
    Mix.Task.run("app.start")

    case Timex.parse(List.first(args), "{YYYY}-{0M}-{D}") do
      {:ok, time} ->
        date = Timex.to_date(time)

        Podcast.public()
        |> Repo.all()
        |> Enum.map(&EpisodeStatsProcessor.new(%{date: date, podcast_id: &1.id}))
        |> Oban.insert_all()

      {:error, _message} ->
        %{}
        |> EpisodeStatsProcessor.new()
        |> Oban.insert!()
    end

    results = Oban.drain_queue(queue: :scheduled, with_recursion: true, with_safety: false)

    Mix.shell().info("Stats processed for #{results.success - 1} dates/podcasts")
  end
end
