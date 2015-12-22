defmodule Changelog.Admin.PageControllerTest do
  use Changelog.ConnCase

  test "GET /" do
    conn = get conn(), "/admin"
    assert html_response(conn, 200) =~ "Admin"
  end
end
