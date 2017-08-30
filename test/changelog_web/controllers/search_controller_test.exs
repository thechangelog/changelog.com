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
      podcast = insert(:podcast)
      episode1 = insert(:published_episode, podcast: podcast, slug: "1", title: "Phoenix")
      episode2 = insert(:published_episode, podcast: podcast, slug: "2", title: "Rails")

      conn = get(build_conn(), search_path(build_conn(), :search, q: "phoenix"))

      assert conn.status == 200
      assert conn.resp_body =~ "1 episode"
      assert conn.resp_body =~ episode1.title
      refute conn.resp_body =~ episode2.title
    end

    test "getting the search with multiple results" do
      podcast = insert(:podcast)
      episode1 = insert(:published_episode, podcast: podcast, slug: "1", title: "Phoenix")
      episode2 = insert(:published_episode, podcast: podcast, slug: "2", title: "Rails")
      post1 = insert(:published_post, title: "Phoenix")
      post2 = insert(:published_post, title: "Rails")

      conn = get(build_conn(), search_path(build_conn(), :search, q: "phoenix"))

      assert conn.status == 200
      assert conn.resp_body =~ "1 episode"
      assert conn.resp_body =~ "1 post"
      assert conn.resp_body =~ episode1.title
      refute conn.resp_body =~ episode2.title
      assert conn.resp_body =~ post1.title
      refute conn.resp_body =~ post2.title
    end

    test "getting the search paginated" do
      podcast = insert(:podcast)
      Enum.map(1..11, fn(x) -> insert(:published_episode, podcast: podcast, title: "Elixir #{x}") end)

      conn = get(build_conn(), search_path(build_conn(), :search, q: "elixir", type: "episodes", page: 2))

      assert conn.status == 200
      assert conn.resp_body =~ "11 episodes"
      assert conn.resp_body =~ "Elixir 1"
      refute conn.resp_body =~ "Elixir 2"
    end

    test "getting the search without results" do
      conn = get(build_conn(), search_path(build_conn(), :search, q: "phoenix"))

      assert conn.status == 200
      assert conn.resp_body =~ "There are no results"
    end
  end
end
