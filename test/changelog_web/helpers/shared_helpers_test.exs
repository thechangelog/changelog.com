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

  test "comma_separated_names" do
    p1 = build(:person, name: "The Gangsta")
    p2 = build(:person, name: "The Killa")
    p3 = build(:person, name: "The Dope Dealer")
    p4 = build(:person, name: "You")

    assert comma_separated_names(nil) == ""
    assert comma_separated_names([]) == ""
    assert comma_separated_names([p1]) == "The Gangsta"
    assert comma_separated_names([p1, p2]) == "The Gangsta and The Killa"
    assert comma_separated_names([p1, p2, p3]) == "The Gangsta, The Killa, and The Dope Dealer"

    assert comma_separated_names([p1, p2, p3, p4]) ==
             "The Gangsta, The Killa, The Dope Dealer, and You"
  end

  describe "percent/2" do
    test "0 when divisor is 0" do
      assert percent(1, 0) == 0
    end

    test "rounds to nearest integer percent" do
      assert percent(5, 22) == 23
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

  describe "mastodon_url/1" do
    test "is empty when nil" do
      assert mastodon_url(nil) == ""
    end

    test "is empty when nil in map" do
      assert mastodon_url(%{mastodon_handle: nil}) == ""
    end

    test "converts handle as string" do
      assert mastodon_url("jerod@changelog.social") == "https://changelog.social/@jerod"
    end

    test "converts handle in map" do
      assert mastodon_url(%{mastodon_handle: "jerod@changelog.social"}) == "https://changelog.social/@jerod"
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
