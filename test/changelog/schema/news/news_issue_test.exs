defmodule Changelog.NewsIssueTest do
  use Changelog.SchemaCase

  alias Changelog.NewsIssue

  describe "layout/1" do
    test "it is v2 when slug is integer > 267" do
      issue = %NewsIssue{slug: "268"}
      assert NewsIssue.layout(issue) == "v2"
    end

    test "it is v1 when slug is integer <= 267" do
      issue = %NewsIssue{slug: "267"}
      assert NewsIssue.layout(issue) == "v1"
    end

    test "it is v1 when slug is non-integer" do
      issue = %NewsIssue{slug: "oh-my"}
      assert NewsIssue.layout(issue) == "v1"
    end
  end

  describe "next_slug/1" do
    test "it defaults to 1" do
      assert NewsIssue.next_slug(nil) == 1
    end

    test "it increments current slug by 1" do
      assert NewsIssue.next_slug(%{slug: "100"}) == 101
    end
  end
end
