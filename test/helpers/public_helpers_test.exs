defmodule Changelog.PublicHelpersTest do
  use Changelog.ConnCase, async: true

  import Changelog.Helpers.PublicHelpers

  describe "no_widowed_words" do
    test "when passed nil" do
      assert no_widowed_words(nil) == ""
    end

    test "when the string is empty" do
      assert no_widowed_words("") == ""
    end

    test "when string has one word" do
      assert no_widowed_words("love") == "love"
    end

    test "when string has two words" do
      assert no_widowed_words("love me") == "love&nbsp;me"
    end

    test "when string has many words" do
      assert no_widowed_words("love me love me say that you love me") == "love me love me say that you love&nbsp;me"
    end
  end

  describe "plural_form" do
    test "when sent a count" do
      assert plural_form(1, "person", "people") == "person"
    end

    test "when sent a list" do
      assert plural_form([1], "person", "people") == "person"
    end
  end
end
