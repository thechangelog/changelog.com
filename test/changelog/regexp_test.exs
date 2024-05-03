defmodule Changelog.RegexpTest do
  use ExUnit.Case

  alias Changelog.Regexp

  test "email requires an @ and a . somewhere after the @" do
    yes = ["changelog-48dafo@e6z9r.net", "jerod+weekly@changelog.com", "x@y.z"]
    no = ["ohai", "this is a test@no thanks com", "x@y", "@jerod@changelog.social"]

    for email <- yes do
      assert String.match?(email, Regexp.email())
    end

    for email <- no do
      refute String.match?(email, Regexp.email())
    end
  end

  test "email cannot have a spaces in them" do
    no = [
      "tester@yandex.ru ",
      " tester@yandex.ru",
      "test er@yandex.ru",
      "tester@yandex .ru",
      "tester@yandex. ru"
    ]

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

  test "top_story" do
    yes = [
      "## ✨ [Cool thing](http://cool.com)",
      "### 👌 [Slightly less cool thing](http://cool.com)"
    ]

    no = ["## ✨ Missing the link", "### [No emoji](http://cool.com)"]

    for top_story <- yes do
      assert String.match?(top_story, Regexp.top_story())
    end

    for top_story <- no do
      refute String.match?(top_story, Regexp.top_story())
    end
  end
end
