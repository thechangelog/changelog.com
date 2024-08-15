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

  describe "exclude/2" do
    test "it excludes by id matching when thing is a map with an id" do
      list = [%{id: 1, name: "1st"}, %{id: 2, name: "2nd"}, %{id: 3, name: "3rd"}]
      assert ListKit.exclude(list, %{id: 2}) == [%{id: 1, name: "1st"}, %{id: 3, name: "3rd"}]
    end

    test "it excludes a single thing from a list" do
      list = [1, 2, 3]
      assert ListKit.exclude(list, 2) == [1, 3]
    end

    test "it excludes nothing when thing is nil" do
      list = [1, 2, 3]
      assert ListKit.exclude(list, nil) == [1, 2, 3]
    end

    test "it excludes a list of things from a list" do
      list = [1, 2, 3, 4, 5]
      assert ListKit.exclude(list, [2, 4]) == [1, 3, 5]
    end
  end

  describe "uniq_merge/2" do
    test "makes one list from two" do
      assert ListKit.uniq_merge([1,2,3], [4,5]) == [1,2,3,4,5]
    end

    test "works with empty lists" do
      assert ListKit.uniq_merge([1,2,3], []) == [1,2,3]
      assert ListKit.uniq_merge([], [4,5]) == [4,5]
    end

    test "doesn't include duplicates" do
      assert ListKit.uniq_merge([1,2,3], [1,2,3]) == [1,2,3]
      assert ListKit.uniq_merge([3,4], [4,5]) == [3,4,5]
    end
  end

  describe "overlap?/2" do
    test "is true when two lists have at least one common element" do
      assert ListKit.overlap?([1, 2, 3], [2, 3, 4])
      assert ListKit.overlap?([1, 2, 3], [1, "two", :three])
    end

    test "is false when two lists have no common elements" do
      refute ListKit.overlap?([1, 2, 3], [4, 5, 6])
      refute ListKit.overlap?([1, 2, 3], ["1", "two", :three])
      refute ListKit.overlap?([1, 2, 3], [])
    end
  end
end
