defmodule ChangelogWeb.AdminHelpersTest do
  use ChangelogWeb.ConnCase, async: true

  alias ChangelogWeb.Helpers.AdminHelpers

  describe "is_persisted/1" do
    test "false when given a struct with a nil id" do
      refute AdminHelpers.is_persisted(%{id: nil})
    end

    test "false when given a struct no id attr" do
      refute AdminHelpers.is_persisted(%{name: "nope"})
    end

    test "false when given a struct with id as empty string" do
      refute AdminHelpers.is_persisted(%{id: ""})
    end

    test "is true when given a struct with an id as integer" do
      assert AdminHelpers.is_persisted(%{id: 1})
    end

    test "true when given a struct with an id as string" do
      assert AdminHelpers.is_persisted(%{id: "8675309"})
    end
  end
end
