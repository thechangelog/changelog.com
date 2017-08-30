defmodule ChangelogWeb.PublicHelpersTest do
  use ChangelogWeb.ConnCase, async: true

  import ChangelogWeb.Helpers.PublicHelpers

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

  describe "with_timestamp_links" do
    test "normal use inside brackets" do
      assert with_timestamp_links("[00:11:24.05]") == ~s{[<a class="timestamp" href="#t=00:11:24.05">00:11:24.05</a>]}
    end

    test "normal use outside brackets" do
      assert with_timestamp_links("yup 00:01:00.5") == ~s{yup <a class="timestamp" href="#t=00:01:00.5">00:01:00.5</a>}
    end

    test "short-hand use" do
      assert with_timestamp_links("[1:24] something") == ~s{[<a class="timestamp" href="#t=1:24">1:24</a>] something}
    end

    test "muliple occurrences" do
      plain = "but [unintelligible 00:15:18.13] has helped with [00:14:19.03] stuff"
      assert with_timestamp_links(plain) == ~s{but [unintelligible <a class="timestamp" href="#t=00:15:18.13">00:15:18.13</a>] has helped with [<a class="timestamp" href="#t=00:14:19.03">00:14:19.03</a>] stuff}
    end
  end
end
