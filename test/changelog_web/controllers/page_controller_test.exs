defmodule ChangelogWeb.PageControllerTest do
  use ChangelogWeb.ConnCase

  test "static pages all render", %{conn: conn} do
    Enum.each([
      "/about",
      "/contact",
      "/films",
      "/community",
      "/join",
      "/nightly",
      "/nightly/confirmed",
      "/nightly/unsubscribed",
      "/partnership",
      "/sponsor",
      "/store",
      "/team",
      "/weekly",
      "/weekly/archive",
      "/weekly/confirmed",
      "/weekly/unsubscribed",
      "/confirmation-pending",
      "/gotime/confirmed",
      "/rfc/confirmed"
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
end
