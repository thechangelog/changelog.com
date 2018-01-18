defmodule ChangelogWeb.SearchControllerTest do
  use ChangelogWeb.ConnCase

  describe "without query" do
    test "getting the search" do
      conn = get(build_conn(), search_path(build_conn(), :search))

      assert conn.status == 200
    end
  end

  describe "with query" do
    test "getting the search with one result" do
      item1 = insert(:published_news_item, headline: "Phoenix", story: "oh my")
      item2 = insert(:published_news_item, headline: "Rails", story: "my oh")

      conn = get(build_conn(), search_path(build_conn(), :search, q: "phoenix"))

      assert conn.status == 200
      assert conn.resp_body =~ "1 item"
      assert conn.resp_body =~ item1.story
      refute conn.resp_body =~ item2.story
    end

    test "getting the search with multiple results" do
      item1 = insert(:published_news_item, headline: "Phoenix", story: "oh my")
      item2 = insert(:published_news_item, headline: "omg phoenix", story: "my oh")

      conn = get(build_conn(), search_path(build_conn(), :search, q: "phoenix"))

      assert conn.status == 200
      assert conn.resp_body =~ "2 items"
      assert conn.resp_body =~ item1.story
      assert conn.resp_body =~ item2.story
    end

    test "getting the search without results" do
      conn = get(build_conn(), search_path(build_conn(), :search, q: "phoenix"))

      assert conn.status == 200
    end
  end
end
