defmodule Changelog.ObanWorkers.EpisodeStatsProcessorTest do
  use Changelog.SchemaCase
  use Oban.Testing, repo: Changelog.Repo

  import Mock

  alias Changelog.{Stats, Episode, Podcast, Repo}
  alias Changelog.ObanWorkers.EpisodeStatsProcessor

  defp log_fixtures(date) do
    file_dir = "#{fixtures_path()}/logs/episodes/#{date}"
    {:ok, files} = File.ls(file_dir)
    Enum.map(files, fn file -> File.read!("#{file_dir}/#{file}") end)
  end

  describe "perform/1" do
    setup_with_mocks([
      {Stats.S3, [], [get_logs: fn _slug, date -> log_fixtures(date) end]},
      {Craisin.Client, [], [stats: fn _group -> %{"Delivered" => 10, "Opened" => 5} end]}
    ]) do
      :ok
    end

    test "inserting jobs for each public podcast and date" do
      podcast1 = insert(:podcast)
      podcast2 = insert(:podcast)

      {:ok, jobs} = perform_job(EpisodeStatsProcessor, %{})

      assert length(jobs) == 4

      args = Enum.map(jobs, & &1.args)

      assert %{"date" => iso_ago(1), "podcast_id" => podcast1.id} in args
      assert %{"date" => iso_ago(2), "podcast_id" => podcast1.id} in args
      assert %{"date" => iso_ago(1), "podcast_id" => podcast2.id} in args
      assert %{"date" => iso_ago(2), "podcast_id" => podcast2.id} in args
    end

    test "it processes known logs from 2016-10-10" do
      podcast = insert(:podcast)

      e1 = insert(:episode, podcast: podcast, slug: "223", audio_bytes: 80_743_303)

      {:ok, stats} = perform_job(EpisodeStatsProcessor, %{date: ~D[2016-10-10], podcast_id: podcast.id})

      assert length(stats) == 1
      stat = get_stat(stats, e1)
      assert stat.downloads == 1.83

      assert refreshed_download_count(e1) == 1.83
      assert refreshed_reach_count(e1) == 3
      assert refreshed_download_count(podcast) == 1.83
      assert refreshed_reach_count(podcast) == 3
    end

    test "it processes known logs from 2016-10-11" do
      podcast = insert(:podcast)

      e1 = insert(:episode, podcast: podcast, slug: "114", audio_bytes: 26_238_621)
      e2 = insert(:episode, podcast: podcast, slug: "181", audio_bytes: 59_310_792)
      e3 = insert(:episode, podcast: podcast, slug: "182", audio_bytes: 56_304_828)
      e4 = insert(:episode, podcast: podcast, slug: "183", audio_bytes: 63_723_737)
      e5 = insert(:episode, podcast: podcast, slug: "202", audio_bytes: 79_743_350)
      e6 = insert(:episode, podcast: podcast, slug: "204", audio_bytes: 70_867_090)
      e7 = insert(:episode, podcast: podcast, slug: "205", audio_bytes: 112_042_496)
      e8 = insert(:episode, podcast: podcast, slug: "207", audio_bytes: 77_737_571)
      e9 = insert(:episode, podcast: podcast, slug: "216", audio_bytes: 81_286_241)
      e10 = insert(:episode, podcast: podcast, slug: "217", audio_bytes: 86_659_297)
      e11 = insert(:episode, podcast: podcast, slug: "218", audio_bytes: 84_495_463)
      e12 = insert(:episode, podcast: podcast, slug: "219", audio_bytes: 62_733_067)
      e13 = insert(:episode, podcast: podcast, slug: "220", audio_bytes: 87_270_178)
      e14 = insert(:episode, podcast: podcast, slug: "221", audio_bytes: 77_652_463)
      e15 = insert(:episode, podcast: podcast, slug: "222", audio_bytes: 81_563_934)
      e16 = insert(:episode, podcast: podcast, slug: "223", audio_bytes: 80_743_303)

      {:ok, stats} = perform_job(EpisodeStatsProcessor, %{date: ~D[2016-10-11], podcast_id: podcast.id})

      assert length(stats) == 16

      stat = get_stat(stats, e1)
      assert stat.downloads == 1
      assert refreshed_download_count(e1) == 1
      assert refreshed_reach_count(e1) == 1
      assert refreshed_email_stats(e1) == {5, 10}

      stat = get_stat(stats, e2)
      assert stat.downloads == 1.06
      assert refreshed_download_count(e2) == 1.06
      assert refreshed_reach_count(e2) == 1
      assert refreshed_email_stats(e1) == {5, 10}

      stat = get_stat(stats, e3)
      assert stat.downloads == 0.04
      assert refreshed_download_count(e3) == 0.04
      assert refreshed_reach_count(e3) == 1

      stat = get_stat(stats, e4)
      assert stat.downloads == 3.2
      assert refreshed_download_count(e4) == 3.2
      assert refreshed_reach_count(e4) == 5

      stat = get_stat(stats, e5)
      assert stat.downloads == 2
      assert refreshed_download_count(e5) == 2
      assert refreshed_reach_count(e5) == 1

      stat = get_stat(stats, e6)
      assert stat.downloads == 1
      assert refreshed_download_count(e6) == 1
      assert refreshed_reach_count(e6) == 1

      stat = get_stat(stats, e7)
      assert stat.downloads == 1
      assert refreshed_download_count(e7) == 1
      assert refreshed_reach_count(e7) == 1

      stat = get_stat(stats, e8)
      assert stat.downloads == 2
      assert refreshed_download_count(e8) == 2
      assert refreshed_reach_count(e8) == 1

      stat = get_stat(stats, e9)
      assert stat.downloads == 2
      assert refreshed_download_count(e9) == 2
      assert refreshed_reach_count(e9) == 1

      stat = get_stat(stats, e10)
      assert stat.downloads == 2.84
      assert refreshed_download_count(e10) == 2.84
      assert refreshed_reach_count(e10) == 5

      stat = get_stat(stats, e11)
      assert stat.downloads == 2.89
      assert refreshed_download_count(e11) == 2.89
      assert refreshed_reach_count(e11) == 3

      stat = get_stat(stats, e12)
      assert stat.downloads == 1
      assert refreshed_download_count(e12) == 1
      assert refreshed_reach_count(e12) == 1

      stat = get_stat(stats, e13)
      assert stat.downloads == 4.22
      assert refreshed_download_count(e13) == 4.22
      assert refreshed_reach_count(e13) == 3

      stat = get_stat(stats, e14)
      assert stat.downloads == 1
      assert refreshed_download_count(e14) == 1
      assert refreshed_reach_count(e14) == 1

      stat = get_stat(stats, e15)
      assert stat.downloads == 5.73
      assert refreshed_download_count(e15) == 5.73
      assert refreshed_reach_count(e15) == 6

      stat = get_stat(stats, e16)
      assert stat.downloads == 10.18
      assert refreshed_download_count(e16) == 10.18
      assert refreshed_reach_count(e16) == 13

      assert refreshed_download_count(podcast) == 41.16
      assert refreshed_reach_count(podcast) == 45
    end

    defp iso_ago(days) do
      Date.utc_today()
      |> Date.add(-days)
      |> Date.to_iso8601()
    end

    defp get_stat(stats, episode) do
      Enum.find(stats, fn x -> x.episode_id == episode.id end)
    end

    defp refreshed_email_stats(%Episode{id: id}) do
      e = Repo.get(Episode, id)
      {e.email_opens, e.email_sends}
    end

    defp refreshed_download_count(%Episode{id: id}) do
      Repo.get(Episode, id).download_count
    end

    defp refreshed_download_count(%Podcast{id: id}) do
      Repo.get(Podcast, id).download_count
    end

    defp refreshed_reach_count(%Episode{id: id}) do
      Repo.get(Episode, id).reach_count
    end

    defp refreshed_reach_count(%Podcast{id: id}) do
      Repo.get(Podcast, id).reach_count
    end
  end
end
