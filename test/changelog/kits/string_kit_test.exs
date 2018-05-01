defmodule Changelog.StringKitTest do
  use ExUnit.Case

  alias Changelog.StringKit

  test "dasherize" do
    assert StringKit.dasherize("The Changelog") == "the-changelog"
    assert StringKit.dasherize("Go Time") == "go-time"
    assert StringKit.dasherize("Hell's Kitchen!") == "hells-kitchen"
  end
end
