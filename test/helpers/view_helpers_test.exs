defmodule Changelog.ViewHelpersTest do
  use Changelog.ConnCase, async: true

  import Changelog.Helpers.ViewHelpers

  describe "pluralize" do
    test "when it is sent a count" do
      assert pluralize(1, "person", "people") == "1 person"
      assert pluralize(0, "person", "people") == "0 people"
      assert pluralize(2, "person", "people") == "2 people"
    end

    test "when sent a list" do
      assert pluralize(["joe"], "host", "hosts") == "1 host"
      assert pluralize([], "host", "hosts") == "0 hosts"
      assert pluralize(["jane", "joe"], "host", "hosts") == "2 hosts"
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
end
