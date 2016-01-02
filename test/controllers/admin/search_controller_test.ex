defmodule Changelog.Admin.SearchControllerTest do
  use Changelog.ConnCase

  @tag :as_admin
  test "searching people", %{conn: conn} do
    create(:person, name: "joe blow")
    create(:person, name: "oh no")

    conn = get conn, "/admin/search?t=person&q=jo"

    assert conn.status == 200
    assert conn.resp_body =~ "joe blow"
    refute conn.resp_body =~ "oh no"
  end
end
