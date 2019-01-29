defmodule ChangelogStatsTest do
  use Changelog.DataCase

  import Mock

  alias Changelog.{Stats, Episode, Podcast, Repo}

  defp log_fixtures(date) do
    file_dir = "#{fixtures_path()}/logs/#{date}"
    {:ok, files} = File.ls(file_dir)
     Enum.map(files, fn(file) -> File.read!("#{file_dir}/#{file}") end)
  end

  describe "process" do
    test_with_mock "it processes known logs from 2016-10-10", Stats.S3,
      [get_logs: fn(date, _slug) -> log_fixtures(date) end] do
      podcast = insert(:podcast)

      e1 = insert(:episode, podcast: podcast, slug: "223", bytes: 80_743_303)

      stats = Stats.process(~D[2016-10-10], podcast)

      assert length(stats) == 1
      stat = get_stat(stats, e1)
      assert stat.downloads == 1.83

      assert refreshed_download_count(e1) == 1.83
      assert refreshed_reach_count(e1) == 3
      assert refreshed_download_count(podcast) == 1.83
      assert refreshed_reach_count(podcast) == 3
    end

    test_with_mock "it processes known logs from 2016-10-11", Stats.S3,
      [get_logs: fn(date, _slug) -> log_fixtures(date) end] do
      podcast = insert(:podcast)

      e1 = insert(:episode, podcast: podcast, slug: "114", bytes: 26_238_621)
      e2 = insert(:episode, podcast: podcast, slug: "181", bytes: 59_310_792)
      e3 = insert(:episode, podcast: podcast, slug: "182", bytes: 56_304_828)
      e4 = insert(:episode, podcast: podcast, slug: "183", bytes: 63_723_737)
      e5 = insert(:episode, podcast: podcast, slug: "202", bytes: 79_743_350)
      e6 = insert(:episode, podcast: podcast, slug: "204", bytes: 70_867_090)
      e7 = insert(:episode, podcast: podcast, slug: "205", bytes: 112_042_496)
      e8 = insert(:episode, podcast: podcast, slug: "207", bytes: 77_737_571)
      e9 = insert(:episode, podcast: podcast, slug: "216", bytes: 81_286_241)
      e10 = insert(:episode, podcast: podcast, slug: "217", bytes: 86_659_297)
      e11 = insert(:episode, podcast: podcast, slug: "218", bytes: 84_495_463)
      e12 = insert(:episode, podcast: podcast, slug: "219", bytes: 62_733_067)
      e13 = insert(:episode, podcast: podcast, slug: "220", bytes: 87_270_178)
      e14 = insert(:episode, podcast: podcast, slug: "221", bytes: 77_652_463)
      e15 = insert(:episode, podcast: podcast, slug: "222", bytes: 81_563_934)
      e16 = insert(:episode, podcast: podcast, slug: "223", bytes: 80_743_303)

      stats = Stats.process(~D[2016-10-11], podcast)
      assert length(stats) == 16

      stat = get_stat(stats, e1)
      assert stat.downloads == 1
      assert refreshed_download_count(e1) == 1
      assert refreshed_reach_count(e1) == 1

      stat = get_stat(stats, e2)
      assert stat.downloads == 1.06
      assert refreshed_download_count(e2) == 1.06
      assert refreshed_reach_count(e2) == 1

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

    defp get_stat(stats, episode) do
      Enum.find(stats, fn(x) -> x.episode_id == episode.id end)
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
