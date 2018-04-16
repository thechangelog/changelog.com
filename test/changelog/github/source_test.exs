defmodule Changelog.Github.SourceTest do
  use ExUnit.Case

  alias Changelog.Github.Source

  test "repo_name/1" do
    assert Source.repo_name("transcripts") == "thechangelog/transcripts"
  end

  test "repo_url/1" do
    assert Source.repo_url("transcripts") == "https://github.com/thechangelog/transcripts"
  end

  test "html_url/2 and raw_url/2 for a Go Time episode" do
    episode = %{slug: "51", podcast: %{name: "Go Time", slug: "gotime"}}

    assert Source.html_url("transcripts", episode) == "https://github.com/thechangelog/transcripts/blob/master/gotime/go-time-51.md"
    assert Source.raw_url("transcripts", episode) == "https://raw.githubusercontent.com/thechangelog/transcripts/master/gotime/go-time-51.md"
  end

  test "html_url/2 and raw_url/2 for an RFC episode" do
    episode = %{slug: "bonus", podcast: %{name: "Request For Commits", slug: "rfc"}}
    assert Source.html_url("transcripts", episode) == "https://github.com/thechangelog/transcripts/blob/master/rfc/request-for-commits-bonus.md"
    assert Source.raw_url("transcripts", episode) == "https://raw.githubusercontent.com/thechangelog/transcripts/master/rfc/request-for-commits-bonus.md"
  end
end
