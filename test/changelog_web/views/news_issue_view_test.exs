defmodule ChangelogWeb.NewsIssueViewTest do
  use ChangelogWeb.ConnCase, async: true

  import ChangelogWeb.NewsIssueView

  describe "items_with_ads" do
    test "with 5 items and 0 ads" do
      items = [1, 2, 3, 4, 5]
      ads = []

      assert items_with_ads(items, ads) == [1, 2, 3, 4, 5]
    end

    test "with 10 items and 2 ads" do
      items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      ads = ["a", "b"]

      assert items_with_ads(items, ads) == [1, 2, 3, "a", 4, 5, 6, "b", 7, 8, 9, 10]
    end

    test "with 10 items and 3 ads" do
      items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      ads = ["a", "b", "c"]

      assert items_with_ads(items, ads) == [1, 2, 3, "a", 4, 5, 6, "b", 7, 8, 9, "c", 10]
    end

    test "with 21 items and 4 ads" do
      items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]
      ads = ["a", "b", "c", "d"]

      assert items_with_ads(items, ads) == [
               1,
               2,
               3,
               "a",
               4,
               5,
               6,
               "b",
               7,
               8,
               9,
               "c",
               10,
               11,
               12,
               "d",
               13,
               14,
               15,
               16,
               17,
               18,
               19,
               20,
               21
             ]
    end
  end
end
