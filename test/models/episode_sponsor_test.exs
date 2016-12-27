defmodule Changelog.EpisodeSponsorTest do
  use Changelog.ModelCase

  alias Changelog.EpisodeSponsor

  describe "admin_changeset" do
    test "valid attributes" do
      changeset = EpisodeSponsor.admin_changeset(%EpisodeSponsor{}, %{position: 42, title: "some content", link_url: "http://apple.com"})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = EpisodeSponsor.admin_changeset(%EpisodeSponsor{}, %{})
      refute changeset.valid?
    end
  end
end
