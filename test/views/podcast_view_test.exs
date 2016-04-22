defmodule Changelog.PodcastViewTest do
  use Changelog.ConnCase, async: true

  import Changelog.PodcastView
  alias Changelog.Podcast

  test "dasherized_name" do
    assert dasherized_name(%Podcast{name: "The Changelog"}) == "the-changelog"
    assert dasherized_name(%Podcast{name: "Go Time"}) == "go-time"
    assert dasherized_name(%Podcast{name: "Hell's Kitchen!"}) == "hells-kitchen"
  end
end
