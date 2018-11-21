defmodule Changelog.ListKitTest do
  use ExUnit.Case

  alias Changelog.ListKit

  describe "compact_join/2" do
    test "it removes nil values and joins list" do
      joined = ListKit.compact_join(["ohai", nil, nil, "there"])
      assert joined == "ohai there"
    end

    test "it removes empty strings and joins list" do
      joined = ListKit.compact_join(["ohai", "", "there"], "-")
      assert joined == "ohai-there"
    end
  end
end
