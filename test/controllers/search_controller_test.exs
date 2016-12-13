defmodule Changelog.SearchControllerTest do
  use Changelog.ConnCase

  describe "without query" do
    test "getting the search" do
      conn = get(build_conn, search_path(build_conn, :search))

      assert conn.status == 200
    end
  end

  describe "with query" do
    test "getting the search with results" do
      podcast = insert(:podcast)
      episode1 = insert(:published_episode, podcast: podcast, slug: "1", title: "Phoenix")
      episode2 = insert(:published_episode, podcast: podcast, slug: "2", title: "Rails")

      conn = get(build_conn, search_path(build_conn, :search, q: "phoenix"))

      assert conn.status == 200
      assert conn.resp_body =~ "1 result"
      assert conn.resp_body =~ episode1.title
      refute conn.resp_body =~ episode2.title
    end

    test "getting the search without results" do
      conn = get(build_conn, search_path(build_conn, :search, q: "phoenix"))

      assert conn.status == 200
      assert conn.resp_body =~ "There are no results"
    end
  end
end
