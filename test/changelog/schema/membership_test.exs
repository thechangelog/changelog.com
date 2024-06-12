defmodule Changelog.MembershipTest do
  use Changelog.SchemaCase

  alias Changelog.Membership

  describe "changeset/2" do
    test "with valid attributes" do
      changeset =
        Membership.changeset(%Membership{}, %{
          subscription_id: "123",
          status: "active",
          person_id: 1
        })

      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Membership.changeset(%Membership{}, %{})
      refute changeset.valid?
    end
  end
end
