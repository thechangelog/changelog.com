defmodule Changelog.EpisodeViewTest do
  use Changelog.ConnCase, async: true

  import Changelog.EpisodeView
  alias Changelog.Episode

  test "megabtyes" do
    assert megabytes(%Episode{bytes: 1000}) == 0
    assert megabytes(%Episode{bytes: 1_000_000}) == 1
    assert megabytes(%Episode{bytes: 68_530_176}) == 69
  end
end
