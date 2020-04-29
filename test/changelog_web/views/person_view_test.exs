defmodule ChangelogWeb.PersonViewTest do
  use ChangelogWeb.ConnCase, async: true

  alias ChangelogWeb.PersonView

  test "external_url" do
    assert PersonView.external_url(build(:person)) == "#"
    assert PersonView.external_url(build(:person, website: "test.com")) == "test.com"
    assert PersonView.external_url(build(:person, twitter_handle: "handle")) == "https://twitter.com/handle"
    assert PersonView.external_url(build(:person, github_handle: "handle")) == "https://github.com/handle"
  end

  test "first_name" do
    assert PersonView.first_name(build(:person, name: "Jane Doe")) == "Jane"
    assert PersonView.first_name(build(:person, name: "John")) == "John"
    assert PersonView.first_name(build(:person, name: "Steve the Geek")) == "Steve"
  end
end
