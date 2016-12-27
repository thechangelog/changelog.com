defmodule Changelog.SponsorTest do
  use Changelog.ModelCase

  alias Changelog.Sponsor

  describe "admin_changeset" do
    test "valid attributes" do
      changeset = Sponsor.admin_changeset(%Sponsor{}, %{name: "Apple, Inc."})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = Sponsor.admin_changeset(%Sponsor{}, %{})
      refute changeset.valid?
    end
  end
end
