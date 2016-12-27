defmodule Changelog.Admin.SearchControllerTest do
  use Changelog.ConnCase

  @tag :as_admin
  test "searching people", %{conn: conn} do
    insert(:person, name: "joe blow")
    insert(:person, name: "oh no")

    conn = get(conn, "/admin/search/person?q=jo&f=json")

    assert conn.status == 200
    assert conn.resp_body =~ "joe blow"
    refute conn.resp_body =~ "oh no"
  end

  @tag :as_admin
  test "searching channels", %{conn: conn} do
    insert(:channel, name: "Elixir Phoenix")
    insert(:channel, name: "Elixir Ecto")

    conn = get(conn, "/admin/search/channel?q=ect&f=json")

    assert conn.status == 200
    assert conn.resp_body =~ "Elixir Ecto"
    refute conn.resp_body =~ "Elixir Phoenix"
  end

  @tag :as_admin
  test "searching sponsors", %{conn: conn} do
    insert(:sponsor, name: "Apple Inc")
    insert(:sponsor, name: "Google Inc")

    conn = get(conn, "/admin/search/sponsor?q=App&f=json")

    assert conn.status == 200
    assert conn.resp_body =~ "Apple Inc"
    refute conn.resp_body =~ "Google"
  end

  test "requires user auth", %{conn: conn} do
    conn = get(conn, "/admin/search/channel?q=ect&f=json")
    assert html_response(conn, 302)
    assert conn.halted
  end
end
