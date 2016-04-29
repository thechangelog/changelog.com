defmodule Changelog.SponsorTest do
  use Changelog.ModelCase

  alias Changelog.Sponsor

  @valid_attrs %{name: "Apple, Inc."}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Sponsor.changeset(%Sponsor{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Sponsor.changeset(%Sponsor{}, @invalid_attrs)
    refute changeset.valid?
  end
end
