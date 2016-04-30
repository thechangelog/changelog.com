defmodule Changelog.EpisodeSponsorTest do
  use Changelog.ModelCase

  alias Changelog.EpisodeSponsor

  @valid_attrs %{position: 42, title: "some content", link_url: "http://apple.com"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = EpisodeSponsor.changeset(%EpisodeSponsor{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = EpisodeSponsor.changeset(%EpisodeSponsor{}, @invalid_attrs)
    refute changeset.valid?
  end
end
