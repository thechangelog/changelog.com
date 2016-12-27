defmodule Changelog.PersonControllerTest do
  use Changelog.ConnCase

  test "getting new person form", %{conn: conn} do
    conn = get(conn, person_path(conn, :new))

    assert conn.status == 200
    assert conn.resp_body =~ "form"
  end

  @tag :as_user
  test "getting new person form when signed in is not allowed", %{conn: conn} do
    conn = get(conn, person_path(conn, :new))
    assert html_response(conn, 302)
    assert conn.halted
  end
end
