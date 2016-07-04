defmodule Changelog.PageControllerTest do
  use Changelog.ConnCase

  test "GET /" do
    conn = get build_conn, "/"
    assert html_response(conn, 200) =~ "Changelog"
  end
end
