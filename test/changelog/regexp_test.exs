defmodule Changelog.RegexpTest do
  use ExUnit.Case

  alias Changelog.Regexp

  test "email requires an @ and a . somewhere after the @" do
    yes = ["changelog-48dafo@e6z9r.net", "jerod+weekly@changelog.com", "x@y.z"]
    no = ["ohai", "this is a test@no thanks com", "x@y"]

    for email <- yes do
      assert String.match?(email, Regexp.email())
    end

    for email <- no do
      refute String.match?(email, Regexp.email())
    end
  end

  test "social requires no http, @, or spaces" do
    yes = ["jerodsanto", "changelog", "This_or-that"]
    no = ["@jerodsanto", "https://github.com/thechangelog", "cool dudette"]

    for social <- yes do
      assert String.match?(social, Regexp.social())
    end

    for social <- no do
      refute String.match?(social, Regexp.social())
    end
  end
end
