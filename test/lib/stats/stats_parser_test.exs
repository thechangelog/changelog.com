defmodule ChangelogStatsParserTest do
  use ExUnit.Case

  alias Changelog.Stats.{Parser, Entry}

  @log1 ~s{<134>2016-10-14T16:56:41Z cache-jfk8141 S3TheChangelog[81772]: 142.169.78.110,[14/Oct/2016:16:56:40 +0000],/uploads/podcast/145/the-changelog-145.mp3,2,206,"AppleCoreMedia/1.0.0.14A403 (iPhone; U; CPU OS 10_0_1 like Mac OS X; en_ca)",45.500,-73.583,"(null)",NA,CA,"Canada"}
  @log2 ~s{<134>2016-10-13T18:09:07Z cache-fra1237 S3TheChangelog[415970]: 78.35.187.78,[13/Oct/2016:18:09:04 +0000],/uploads/podcast/219/the-changelog-219.mp3,262144,200,"Mozilla/5.0 (Linux; Android 6.0.1; HUAWEI RIO-L01 Build/HuaweiRIO-L01) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.124 Mobile Safari/537.36",50.933,6.950,"Köln",EU,DE,"Germany"}
  @log3 ~s{<134>2016-10-14T06:21:01Z cache-bma7035 S3TheChangelog[465510]: 122.163.200.110,[14/Oct/2016:06:18:55 +0000],/uploads/podcast/204/the-changelog-204.mp3,13132042,206,""Mozilla/5.0 (Windows NT 6.1; WOW64; rv:47.0) Gecko/20100101 Firefox/47.0"",26.850,80.917,"Lucknow",AS,IN,"India"}
  @log4 ~s{<134>2016-11-03T09:06:02Z cache-cdg8721 S3TheChangelog[301760]: 149.202.170.38,[03/Nov/2016:09:06:00 +0000],/uploads/podcast/224/the-changelog-224.mp3,0,200,"<div style="display:none;">",48.867,2.333,"Paris",EU,FR,"France"}
  @log5 ~s{<134>2016-10-17T06:32:48Z cache-fra1224 S3GoTime[326477]: 178.189.150.213,[17/Oct/2016:06:32:47 +0000],/uploads/gotime/19/go-time-19.mp3,328417,200,"",47.100,15.933,"Ilz",EU,AT,"Austria"}
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
      # actually 73 lines, but 26 of them have 0 byte entries and 1 is a 301 redirect
      assert length(entries) == (73 - 26 - 1)
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
        country_name: "Canada"}
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
        country_name: "Germany"}
    end

    test "it parses log3 (which contains double quotes in the user agent) in to a valid Entry" do
      assert Parser.parse_line(@log3) == %Entry{
        ip: "122.163.200.110",
        episode: "204",
        bytes: 13132042,
        status: 206,
        agent: "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:47.0) Gecko/20100101 Firefox/47.0",
        latitude: 26.850,
        longitude: 80.917,
        city_name: "Lucknow",
        continent_code: "AS",
        country_code: "IN",
        country_name: "India"}
    end

    test "it parses log5 (which has a blank user agent) in to a valid Entry" do
      assert Parser.parse_line(@log5) == %Entry{
        ip: "178.189.150.213",
        episode: "19",
        bytes: 328417,
        status: 200,
        agent: "",
        latitude: 47.100,
        longitude: 15.933,
        city_name: "Ilz",
        continent_code: "EU",
        country_code: "AT",
        country_name: "Austria"}
    end

    test "it rescues CSV parse errors and returns a 0 byte entry otherwise" do
      assert Parser.parse_line(@log4) == %Entry{bytes: 0}
    end
  end
end
