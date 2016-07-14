defmodule Changelog.PageControllerTest do
  use Changelog.ConnCase

  test "static pages all render" do
    Enum.each([
      "/",
      "/weekly",
      "/nightly",
      "/contact",
      "/films",
      "/membership",
      "/sponsorship",
      "/partnership",
      "/store",
      "/team",
      "/about"
    ], fn route ->
      conn = get(build_conn, route)
      assert conn.status == 200
    end)
  end
end
