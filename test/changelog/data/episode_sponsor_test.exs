defmodule Changelog.EpisodeSponsorTest do
  use Changelog.DataCase

  alias Changelog.EpisodeSponsor

  describe "changeset" do
    test "valid attributes" do
      changeset = EpisodeSponsor.changeset(%EpisodeSponsor{}, %{position: 42, title: "some content", link_url: "http://apple.com"})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = EpisodeSponsor.changeset(%EpisodeSponsor{}, %{})
      refute changeset.valid?
    end
  end
end
