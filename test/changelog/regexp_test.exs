defmodule Changelog.RegexpTest do
  use ExUnit.Case

  alias Changelog.Regexp

  test "email requires an @ and a . somewhere after the @" do
    yes = ["changelog-48dafo@e6z9r.net", "jerod+weekly@changelog.com", "x@y.z"]
    no = ["ohai", "this is a test@no thanks com", "x@y"]

    for email <- yes do
      assert String.match?(email, Regexp.email)
    end

    for email <- no do
      refute String.match?(email, Regexp.email)
    end
  end
end
