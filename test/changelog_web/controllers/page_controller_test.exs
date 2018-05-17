defmodule ChangelogWeb.PageControllerTest do
  use ChangelogWeb.ConnCase

  test "static pages all render", %{conn: conn} do
    Enum.each([
      "/about",
      "/contact",
      "/films",
      "/community",
      "/nightly",
      "/sponsor",
      "/sponsor/pricing",
      "/team",
      "/weekly",
      "/weekly/archive"
    ], fn route ->
      conn = get(conn, route)
      assert conn.status == 200
    end)
  end

  describe "guest" do
    test "it falls back to The Changelog with no slug", %{conn: conn} do
      changelog = insert(:podcast, name: "The Changelog", slug: "podcast")
      conn = get(conn, "/guest")
      assert html_response(conn, 200) =~ changelog.name
    end

    test "it uses the provided Podcast slug", %{conn: conn} do
      rfc = insert(:podcast, name: "Request For Commits", slug: "rfc")
      conn = get(conn, "/guest/rfc")
      assert html_response(conn, 200) =~ rfc.name
    end
  end

  describe "sponsor stories" do
    test "it renders for all known sponsor stories", %{conn: conn} do
      for story <- Changelog.SponsorStory.all() do
        conn = get(conn, page_path(conn, :sponsor_story, story.slug))
        assert html_response(conn, 200) =~ story.sponsor
      end
    end

    test "it falls back to the rollbar story", %{conn: conn} do
      conn = get(conn, page_path(conn, :sponsor_story, "ohai"))
      assert html_response(conn, 200) =~ "Rollbar"
    end
  end
end
