defmodule Changelog.EpisodeStatTest do
  use Changelog.DataCase

  alias Changelog.EpisodeStat

  @valid_attrs %{date: Timex.today, episode_id: 1, podcast_id: 1}
  @invalid_attrs %{}
  @demo Poison.decode!(File.read!("#{fixtures_path()}/demographics.json"))

  test "changeset with valid attributes" do
    changeset = EpisodeStat.changeset(%EpisodeStat{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = EpisodeStat.changeset(%EpisodeStat{}, @invalid_attrs)
    refute changeset.valid?
  end

  describe "downloads_by_browser" do
    test "when passed one stat, it returns downloads grouped by browser" do
      stat = build(:episode_stat, date: ~D[2016-01-01], demographics: @demo)

      by_browser = EpisodeStat.downloads_by_browser(stat)

      assert Enum.take(by_browser, 2) == [{"Unknown", 126.13}, {"Android", 47.19}]
    end

    test "when passed multiple stats, it returns downloads grouped by browser" do
      stat1 = build(:episode_stat, date: ~D[2016-01-01], demographics: @demo)
      stat2 = build(:episode_stat, date: ~D[2016-01-02], demographics: @demo)

      by_browser = EpisodeStat.downloads_by_browser([stat1, stat2])

      assert Enum.take(by_browser, 2) == [{"Unknown", 252.26}, {"Android", 94.38}]
      assert List.last(by_browser) == {"YandexBot", 0.0}
    end
  end

  describe "downloads_by_country" do
    test "when passed one stat, it returns downloads sorted by country" do
      stat = build(:episode_stat, demographics: @demo)

      by_country = EpisodeStat.downloads_by_country(stat)

      assert Enum.take(by_country, 3) == [{"US", 2580.03}, {"GB", 390.35}, {"DE", 288.95}]
      assert Enum.take(by_country, -2) == [{"AW", 0.0}, {"NP", 0.0}]
    end

    test "when passed multiple stats, it returns downloads sorted by country" do
      stat1 = build(:episode_stat, date: ~D[2016-01-01], demographics: @demo)
      stat2 = build(:episode_stat, date: ~D[2016-01-02], demographics: @demo)
      stat3 = build(:episode_stat, date: ~D[2016-01-03], demographics: %{"countries" => %{"JS" => 6666.6}})

      by_country = EpisodeStat.downloads_by_country([stat1, stat2, stat3])

      assert Enum.take(by_country, 4) == [{"JS", 6666.6}, {"US", 5160.06}, {"GB", 780.7}, {"DE", 577.9}]
      assert Enum.take(by_country, -2) == [{"AW", 0.0}, {"NP", 0.0}]
    end
  end

  describe "downloads_by_client" do
    test "when passed one stat, it returns downloads grouped/sorted by agent" do
      stat = build(:episode_stat, demographics: @demo)

      by_agent = EpisodeStat.downloads_by_client(stat)

      assert Enum.take(by_agent, 3) == [{"Overcast", 1819.94}, {"AppleCoreMedia", 1192.24}, {"Pocket Casts", 889.2}]
      assert List.last(by_agent) == {"itunesstored", 0.0}
    end

    test "when passed multiple stats, it returns downloads grouped/sorted by agent" do
      stat1 = build(:episode_stat, date: ~D[2016-01-01], demographics: @demo)
      stat2 = build(:episode_stat, date: ~D[2016-01-02], demographics: @demo)

      by_agent = EpisodeStat.downloads_by_client([stat1, stat2])

      assert Enum.take(by_agent, 3) == [{"Overcast", 3639.88}, {"AppleCoreMedia", 2384.48}, {"Pocket Casts", 1778.4}]
    end
  end

  describe "downloads_by_os" do
    test "when passed one stat, it returns downloads grouped by OS" do
      stat = build(:episode_stat, date: ~D[2016-01-01], demographics: @demo)

      by_os = EpisodeStat.downloads_by_os(stat)

      assert Enum.take(by_os, 2) == [{"Linux", 100.44}, {"Android", 55.4}]
    end

    test "when passed multiple stats, it returns downloads grouped by browser" do
      stat1 = build(:episode_stat, date: ~D[2016-01-01], demographics: @demo)
      stat2 = build(:episode_stat, date: ~D[2016-01-02], demographics: @demo)

      by_os = EpisodeStat.downloads_by_os([stat1, stat2])

      assert Enum.take(by_os, 2) == [{"Linux", 200.88}, {"Android", 110.8}]
      assert List.last(by_os) == {"Windows XP", 0.0}
    end
  end
end
