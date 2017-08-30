defmodule Changelog.Transcripts.SourceTest do
  use ExUnit.Case

  alias Changelog.Transcripts.Source

  test "repo_name" do
    assert Source.repo_name == "thechangelog/transcripts"
  end

  test "repo_url" do
    assert Source.repo_url == "https://github.com/thechangelog/transcripts"
  end

  test "html_url and raw_url for a Go Time episode" do
    episode = %{slug: "51", podcast: %{name: "Go Time", slug: "gotime"}}

    assert Source.html_url(episode) == "https://github.com/thechangelog/transcripts/blob/master/gotime/go-time-51.md"
    assert Source.raw_url(episode) == "https://raw.githubusercontent.com/thechangelog/transcripts/master/gotime/go-time-51.md"
  end

  test "html_url and raw_url for an RFC episode" do
    episode = %{slug: "bonus", podcast: %{name: "Request For Commits", slug: "rfc"}}
    assert Source.html_url(episode) == "https://github.com/thechangelog/transcripts/blob/master/rfc/request-for-commits-bonus.md"
    assert Source.raw_url(episode) == "https://raw.githubusercontent.com/thechangelog/transcripts/master/rfc/request-for-commits-bonus.md"
  end
end
