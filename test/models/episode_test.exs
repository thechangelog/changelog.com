defmodule Changelog.EpisodeTest do
  use Changelog.ModelCase

  alias Changelog.Episode

  @valid_attrs %{slug: "181", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Episode.changeset(%Episode{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Episode.changeset(%Episode{}, @invalid_attrs)
    refute changeset.valid?
  end

  describe "validating featured episodes" do
    test "featured changeset that is missing a highlight" do
      changeset = Episode.changeset(build(:episode), %{featured: true})
      refute changeset.valid?
    end

    test "featured changeset that includes a highlight" do
      changeset = Episode.changeset(build(:episode), %{featured: true, highlight: "Much wow"})
      assert changeset.valid?
    end
  end
end
