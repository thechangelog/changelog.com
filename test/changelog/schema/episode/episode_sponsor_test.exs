defmodule Changelog.EpisodeSponsorTest do
  use Changelog.SchemaCase

  alias Changelog.EpisodeSponsor

  describe "changeset" do
    test "valid attributes" do
      changeset =
        EpisodeSponsor.changeset(%EpisodeSponsor{}, %{
          position: 42,
          title: "some content",
          link_url: "http://apple.com"
        })

      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = EpisodeSponsor.changeset(%EpisodeSponsor{}, %{})
      refute changeset.valid?
    end

  end

  describe "validating ends_at" do
    test "invalid when no starts_at" do
      es = build(:episode_sponsor)
      changeset = EpisodeSponsor.changeset(es, %{starts_at: nil, ends_at: 13.0})
      refute changeset.valid?
    end

    test "invalid when before starts_at" do
      es = build(:episode_sponsor)
      changeset = EpisodeSponsor.changeset(es, %{starts_at: 14.5, ends_at: 13.0})
      refute changeset.valid?
    end

    test "valid when after starts_at" do
      es = build(:episode_sponsor)
      changeset = EpisodeSponsor.changeset(es, %{starts_at: 14.5, ends_at: 14.6})
      assert changeset.valid?
    end
  end
end
