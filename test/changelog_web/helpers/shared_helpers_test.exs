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

  describe "domain_name" do
    test "includes subdomain by default" do
      assert domain_name("https://blog.jerodsanto.net/2018") == "blog.jerodsanto.net"
    end

    test "excludes www subdomains" do
      assert domain_name("http://www.theverge.com") == "theverge.com"
    end
  end

  describe "is_future?" do
    test "tests as of current time when given future DateTime" do
      assert is_future?(hours_from_now(1))
      refute is_future?(hours_ago(1))
    end

    test "tests as of given time when given future DateTIme" do
      assert is_future?(hours_from_now(2), hours_from_now(1))
      refute is_future?(hours_from_now(1), hours_from_now(2))
    end
  end

  describe "is_past?" do
    test "tests as of current time when given past DateTime" do
      refute is_past?(hours_from_now(1))
      assert is_past?(hours_ago(1))
    end

    test "tests as of given time when given past DateTIme" do
      refute is_past?(hours_from_now(2), hours_from_now(1))
      assert is_past?(hours_from_now(1), hours_from_now(2))
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
