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

  test "with_numbered_slug" do
    insert :episode, slug: "bonus-episode-dont-find-me"

    yes1 = insert :episode, slug: "204"
    yes2 = insert :episode, slug: "99"

    found_titles =
      Episode.with_numbered_slug
      |> Repo.all
      |> Enum.map(&(&1.title))

    assert found_titles == [yes1.title, yes2.title]
  end
end
