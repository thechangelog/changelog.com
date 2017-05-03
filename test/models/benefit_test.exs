defmodule Changelog.BenefitTest do
  use Changelog.ModelCase

  alias Changelog.Benefit

  test "changeset with valid attributes" do
    changeset = Benefit.changeset(%Benefit{}, %{offer: "Free stuff!", sponsor_id: 1})
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Benefit.changeset(%Benefit{}, %{})
    refute changeset.valid?
  end
end
