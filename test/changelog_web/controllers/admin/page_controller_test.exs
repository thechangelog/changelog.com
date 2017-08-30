defmodule ChangelogWeb.Admin.PageControllerTest do
  use ChangelogWeb.ConnCase

  @tag :as_admin
  test "GET /", %{conn: conn} do
    conn = get conn, "/admin"
    assert html_response(conn, 200) =~ "Admin"
  end
end
