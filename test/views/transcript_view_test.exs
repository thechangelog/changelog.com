defmodule Changelog.TranscriptViewTest do
  use Changelog.ConnCase, async: true

  import Changelog.TranscriptView
  alias Changelog.{TranscriptFragment}

  test "fragment_short_id" do
    fragment = %TranscriptFragment{id: "2b537ef7-f941-4644-b1b9-de2e12b05b95"}
    assert fragment_short_id(fragment) == "2b537ef7"
  end

  test "fragment_permalink" do
    fragment = %TranscriptFragment{id: "c8de7e4c-ea99-4783-9d62-c283b01cb397"}
    assert fragment_permalink(fragment) == "#c8de7e4c"
  end
end
