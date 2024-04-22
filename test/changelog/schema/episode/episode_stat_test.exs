defmodule Changelog.EpisodeStatTest do
  use Changelog.SchemaCase

  alias Changelog.EpisodeStat

  @valid_attrs %{date: Timex.today(), episode_id: 1, podcast_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = EpisodeStat.changeset(%EpisodeStat{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = EpisodeStat.changeset(%EpisodeStat{}, @invalid_attrs)
    refute changeset.valid?
  end
end
