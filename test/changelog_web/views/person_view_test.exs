defmodule ChangelogWeb.PersonViewTest do
  use ChangelogWeb.ConnCase, async: true

  import ChangelogWeb.PersonView

  test "external_url" do
    assert external_url(build(:person)) == "#"
    assert external_url(build(:person, website: "test.com")) == "test.com"
    assert external_url(build(:person, twitter_handle: "handle")) == "https://twitter.com/handle"
    assert external_url(build(:person, github_handle: "handle")) == "https://github.com/handle"
  end

  test "first_name" do
    assert first_name(build(:person, name: "Jane Doe")) == "Jane"
    assert first_name(build(:person, name: "John")) == "John"
    assert first_name(build(:person, name: "Steve the Geek")) == "Steve"
  end
end
