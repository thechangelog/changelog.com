defmodule Changelog.Github.SourceTest do
  use ExUnit.Case

  alias Changelog.Github.Source

  test "repo_regex/0" do
    assert Regex.match?(Source.repo_regex(), "thechangelog/transcripts")
    refute Regex.match?(Source.repo_regex(), "thechangelog/nightly")
    refute Regex.match?(Source.repo_regex(), "jerodsanto/changelog.com")
  end

  test "repo_url" do
    source = Source.new("show-notes", %{slug: "51", podcast: %{name: "Go Time", slug: "gotime"}})
    assert source.repo_url == "https://github.com/thechangelog/show-notes"
  end

  test "html_url and raw_url for a Go Time episode" do
    source = Source.new("transcripts", %{slug: "51", podcast: %{name: "Go Time", slug: "gotime"}})
    assert source.html_url == "https://github.com/thechangelog/transcripts/blob/master/gotime/go-time-51.md"
    assert source.raw_url == "https://raw.githubusercontent.com/thechangelog/transcripts/master/gotime/go-time-51.md"
  end

  test "html_url and raw_url for an RFC episode" do
    source = Source.new("transcripts", %{slug: "bonus", podcast: %{name: "Request For Commits", slug: "rfc"}})
    assert source.html_url == "https://github.com/thechangelog/transcripts/blob/master/rfc/request-for-commits-bonus.md"
    assert source.raw_url == "https://raw.githubusercontent.com/thechangelog/transcripts/master/rfc/request-for-commits-bonus.md"
  end
end
