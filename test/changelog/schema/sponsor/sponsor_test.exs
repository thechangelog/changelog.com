defmodule Changelog.SponsorTest do
  use Changelog.SchemaCase

  alias Changelog.{Sponsor}

  describe "insert_changeset" do
    test "valid attributes" do
      changeset = Sponsor.insert_changeset(%Sponsor{}, %{name: "Apple, Inc."})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = Sponsor.insert_changeset(%Sponsor{}, %{})
      refute changeset.valid?
    end
  end
end
