defmodule Changelog.BenefitTest do
  use Changelog.ModelCase

  alias Changelog.Benefit

  describe "admin_changeset" do
    test "with valid attributes" do
      changeset = Benefit.admin_changeset(%Benefit{}, %{offer: "Free stuff!", sponsor_id: 1})
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Benefit.admin_changeset(%Benefit{}, %{})
      refute changeset.valid?
    end
  end
end
