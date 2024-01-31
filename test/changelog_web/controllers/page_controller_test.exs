defmodule ChangelogWeb.PageControllerTest do
  use ChangelogWeb.ConnCase

  test "static pages all render", %{conn: conn} do
    Enum.each(
      [
        "/about",
        "/contact",
        "/films",
        "/community",
        "/nightly",
        "/manifest.json"
      ],
      fn route ->
        conn = get(conn, route)
        assert conn.status == 200
      end
    )
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

  describe "plusplus" do
    test "it redirects to supercast from /++", %{conn: conn} do
      conn = get(conn, "/++")
      assert redirected_to(conn) == Application.get_env(:changelog, :plusplus_url)
    end

    test "it redirects to supercast from /plusplus", %{conn: conn} do
      conn = get(conn, "/plusplus")
      assert redirected_to(conn) == Application.get_env(:changelog, :plusplus_url)
    end
  end
end
