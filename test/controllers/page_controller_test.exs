defmodule Changelog.PageControllerTest do
  use Changelog.ConnCase

  test "static pages all render" do
    Enum.each([
      "/",
      "/about",
      "/contact",
      "/films",
      "/membership",
      "/nightly",
      "/nightly/confirmation-pending",
      "/nightly/confirmed",
      "/nightly/unsubscribed",
      "/partnership",
      "/sponsorship",
      "/store",
      "/team",
      "/weekly",
      "/weekly/archive",
      "/weekly/confirmed",
      "/weekly/confirmation-pending",
      "/weekly/unsubscribed",
    ], fn route ->
      conn = get(build_conn, route)
      assert conn.status == 200
    end)
  end
end
