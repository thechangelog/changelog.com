defmodule Changelog.PageControllerTest do
  use Changelog.ConnCase

  test "static pages all render", %{conn: conn} do
    Enum.each([
      "/",
      "/about",
      "/contact",
      "/films",
      "/community",
      "/nightly",
      "/nightly/confirmed",
      "/nightly/unsubscribed",
      "/partnership",
      "/sponsorship",
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

  test "home page includes featured episode", %{conn: conn} do
    featured = insert :published_episode, featured: true, highlight: "ohai"

    conn = get(conn, "/")

    assert html_response(conn, 200) =~ featured.title
  end
end
