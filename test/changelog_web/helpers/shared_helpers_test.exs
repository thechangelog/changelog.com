defmodule ChangelogWeb.SharedHelpersTest do
  use ChangelogWeb.ConnCase, async: true

  import ChangelogWeb.Helpers.SharedHelpers

  describe "comma_separated" do
    test "it separates integers with commas" do
      assert comma_separated(123_456_123) == "123,456,123"
      assert comma_separated(1234) == "1,234"
      assert comma_separated(0) == "0"
    end
  end

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
end
