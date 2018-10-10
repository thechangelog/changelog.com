defmodule ChangelogStatsAnalyzerTest do
  use ExUnit.Case

  alias Changelog.Stats.{Analyzer, Entry}

  describe "downloads" do
    test "it defaults to 0" do
      assert Analyzer.downloads([], 1000) == 0
      assert Analyzer.downloads([], 0) == 0
    end

    test "it derives downloads from episode bytes and entries bytes" do
      entries = [
        %Entry{bytes: 2500},
        %Entry{bytes: 1750},
        %Entry{bytes: 0},
        %Entry{bytes: 3999}
      ]

      assert Analyzer.downloads(entries, 1000) == 8.25
      assert Analyzer.downloads(entries, 1500) == 5.5
    end
  end

  describe "bytes" do
    test "it defaults to 0" do
      assert Analyzer.bytes([]) == 0
    end

    test "it sums the bytes of all the entries given" do
      entries = [
        %Entry{bytes: 512},
        %Entry{bytes: 512},
        %Entry{bytes: 0}
      ]

      assert Analyzer.bytes(entries) == 1024
    end
  end

  describe "downloads_by" do
    test "it can sum and sort downloads by agent" do
      entries = [
        %Entry{agent: "Agent Orange", bytes: 4000},
        %Entry{agent: "Agent Orange", bytes: 4000},
        %Entry{agent: "Mr. Pink", bytes: 8000},
        %Entry{agent: "Mr. Pink", bytes: 12},
        %Entry{agent: "Prof Plum", bytes: 0},
      ]

      assert Analyzer.downloads_by(entries, :agent, 1000) == %{
        "Mr. Pink" => 8.01,
        "Agent Orange" => 8.0,
        "Prof Plum" => 0
      }
    end

    test "it can sum and sort bytes by country" do
      entries = [
        %Entry{country_code: "US", bytes: 10_241_024},
        %Entry{country_code: "US", bytes: 5_120_000},
        %Entry{country_code: "CA", bytes: 456},
        %Entry{country_code: "CA", bytes: 123_000},
        %Entry{country_code: "DE", bytes: 1},
      ]
      assert Analyzer.downloads_by(entries, :country_code, 1024) == %{
        "US" => 15_001,
        "CA" => 120.56,
        "DE" => 0
      }
    end
  end

  describe "uniques_count" do
    test "it sums the unique IP addresses in the entries given" do
      entries = [
        %Entry{ip: "1.1.1.1"},
        %Entry{ip: "1.2.3.4"},
        %Entry{ip: "1.1.1.1"},
        %Entry{ip: "1.2.3.4"},
        %Entry{ip: "4.3.2.1"}
      ]

      assert Analyzer.uniques_count(entries) == 3
    end
  end
end
