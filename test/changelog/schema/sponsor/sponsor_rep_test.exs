defmodule Changelog.SponsorRepTest do
  use Changelog.SchemaCase

  alias Changelog.SponsorRep

  describe "changeset" do
    test "valid attributes" do
      changeset =
        SponsorRep.changeset(%SponsorRep{}, %{})
      assert changeset.valid?
    end
  end
end
