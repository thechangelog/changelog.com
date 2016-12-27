defmodule Changelog.PersonControllerTest do
  use Changelog.ConnCase

  test "getting new person form", %{conn: conn} do
    conn = get(conn, person_path(conn, :new))

    assert conn.status == 200
    assert conn.resp_body =~ "form"
  end
end
