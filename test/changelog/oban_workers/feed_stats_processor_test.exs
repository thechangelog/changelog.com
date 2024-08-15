defmodule Changelog.ObanWorkers.FeedStatsProcessorTest do
  use Changelog.SchemaCase
  use Oban.Testing, repo: Changelog.Repo

  import Mock

  alias Changelog.{Feed, FeedStat, Podcast, Repo, Stats}
  alias Changelog.ObanWorkers.FeedStatsProcessor

  defp log_fixtures(date) do
    file_dir = "#{fixtures_path()}/logs/feeds/#{date}"
    {:ok, files} = File.ls(file_dir)
    Enum.map(files, fn file -> File.read!("#{file_dir}/#{file}") end)
  end

  describe "perform/1" do
    setup_with_mocks([
      {Stats.S3, [], [get_logs: fn _slug, date -> log_fixtures(date) end]}
    ]) do
      :ok
    end

    test "it processes known logs from 2024-08-09" do
      gotime = insert(:podcast, slug: "gotime")
      jsparty = insert(:podcast, slug: "jsparty")
      feed = insert(:feed, slug: "A1D5691802E8D20DEA94C6E9821AFBB2")

      :ok = perform_job(FeedStatsProcessor, %{"date" => "2024-08-09"})

      assert Repo.count(Ecto.assoc(gotime, :feed_stats)) == 1
      assert Repo.count(Ecto.assoc(jsparty, :feed_stats)) == 1
      assert Repo.count(Ecto.assoc(feed, :feed_stats)) == 1
      assert Repo.count(FeedStat.on_date("2024-08-09")) == 3

      assert Repo.get(Podcast, gotime.id).subscribers == %{"Feedly" => 540, "Overcast feed parser" => 3040}
      assert Repo.get(Feed, feed.id).agents == ["Pocket Casts"]
    end
  end
end
