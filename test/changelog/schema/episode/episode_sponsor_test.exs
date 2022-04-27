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

  describe "duration/1" do
    test "defaults to 60 seconds when starts_at or ends_at not available" do
      assert EpisodeSponsor.duration(%{starts_at: nil, ends_at: nil}) == 60
      assert EpisodeSponsor.duration(%{starts_at: 12.0, ends_at: nil}) == 60
      assert EpisodeSponsor.duration(%{starts_at: nil, ends_at: 345}) == 60
    end

    test "subtracts and rounds ends_at from starts_at" do
      assert EpisodeSponsor.duration(%{starts_at: 12.5, ends_at: 72.5}) == 60
      assert EpisodeSponsor.duration(%{starts_at: 345, ends_at: 436.3}) == 91
      assert EpisodeSponsor.duration(%{starts_at: 123.456, ends_at: 564.12}) == 441
    end

    test "sums a list of sponsors for total duration" do
      sponsors = [
        %{starts_at: 12.5, ends_at: 72.5},
        %{starts_at: 345, ends_at: 436.3},
        %{starts_at: 123.456, ends_at: 564.12}
      ]

      assert EpisodeSponsor.duration(sponsors) == 592
    end
  end
end
