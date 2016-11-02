defmodule ChangelogStatsParserTest do
  use ExUnit.Case

  alias Changelog.Stats.{Parser, Entry}

  @log1 ~s{<134>2016-10-14T16:56:41Z cache-jfk8141 S3TheChangelog[81772]: 142.169.78.110,[14/Oct/2016:16:56:40 +0000],/uploads/podcast/145/the-changelog-145.mp3,2,206,"AppleCoreMedia/1.0.0.14A403 (iPhone; U; CPU OS 10_0_1 like Mac OS X; en_ca)",45.500,-73.583,"(null)",NA,CA,"Canada"}
  @log2 ~s{<134>2016-10-13T18:09:07Z cache-fra1237 S3TheChangelog[415970]: 78.35.187.78,[13/Oct/2016:18:09:04 +0000],/uploads/podcast/219/the-changelog-219.mp3,262144,200,"Mozilla/5.0 (Linux; Android 6.0.1; HUAWEI RIO-L01 Build/HuaweiRIO-L01) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.124 Mobile Safari/537.36",50.933,6.950,"Köln",EU,DE,"Germany"}
  @file1 ~s{test/fixtures/logs/2016-10-14T13:00:00.000-oe6twX9qexnc62cAAAAA.log}
  @file2 ~s{test/fixtures/logs/2016-10-13T08:00:00.000-aQlu8sDqCqHgsnMAAAAA.log}

  describe "parse_files" do
    test "it creates a list with all the entries for the list of files given" do
      entries = Parser.parse_files([@file1, @file2])
      # actually 73 lines, but 26 of them have 0 byte entries
      assert length(entries) == (73 - 26)
    end
  end

  describe "parse_file" do
    test "it creates a list with one entry when file has one line in it" do
      entries = Parser.parse_file(@file1)
      assert length(entries) == 1
    end

    test "it creates a list with many entries when file has many lines in it" do
      entries = Parser.parse_file(@file2)
      # actually 72 lines, but 26 of them have 0 byte entries
      assert length(entries) == (72 - 26)
    end
  end

  describe "parse_line" do
    test "it parses log1 into a value Entry" do
      assert Parser.parse_line(@log1) == %Entry{
        ip: "142.169.78.110",
        episode: "145",
        bytes: 2,
        status: 206,
        agent: "AppleCoreMedia/1.0.0.14A403 (iPhone; U; CPU OS 10_0_1 like Mac OS X; en_ca)",
        latitude: 45.5,
        longitude: -73.583,
        city_name: "Unknown",
        continent_code: "NA",
        country_code: "CA",
        country_name: "Canada"
      }
    end

    test "it parses log2 in to a valid Entry" do
      assert Parser.parse_line(@log2) == %Entry{
        ip: "78.35.187.78",
        episode: "219",
        bytes: 262144,
        status: 200,
        agent: "Mozilla/5.0 (Linux; Android 6.0.1; HUAWEI RIO-L01 Build/HuaweiRIO-L01) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.124 Mobile Safari/537.36",
        latitude: 50.933,
        longitude: 6.950,
        city_name: "Köln",
        continent_code: "EU",
        country_code: "DE",
        country_name: "Germany"
      }
    end
  end
end
