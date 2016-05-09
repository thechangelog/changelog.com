defmodule Changelog.Admin.SearchControllerTest do
  use Changelog.ConnCase

  @tag :as_admin
  test "searching people", %{conn: conn} do
    create :person, name: "joe blow"
    create :person, name: "oh no"

    conn = get conn, "/admin/search?t=person&q=jo"

    assert conn.status == 200
    assert conn.resp_body =~ "joe blow"
    refute conn.resp_body =~ "oh no"
  end

  @tag :as_admin
  test "searching channels", %{conn: conn} do
    create :channel, name: "Elixir Phoenix"
    create :channel, name: "Elixir Ecto"

    conn = get conn, "/admin/search?t=channel&q=ect"

    assert conn.status == 200
    assert conn.resp_body =~ "Elixir Ecto"
    refute conn.resp_body =~ "Elixir Phoenix"
  end

  @tag :as_admin
  test "searching sponsors", %{conn: conn} do
    create :sponsor, name: "Apple Inc"
    create :sponsor, name: "Google Inc"

    conn = get conn, "/admin/search?t=sponsor&q=App"

    assert conn.status == 200
    assert conn.resp_body =~ "Apple Inc"
    refute conn.resp_body =~ "Google"
  end

  test "requires user auth" do
    conn = get conn, "/admin/search?t=channel&q=ect"
    assert html_response(conn, 302)
    assert conn.halted
  end
end
