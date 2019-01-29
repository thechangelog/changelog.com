defmodule ChangelogWeb.Admin.SearchControllerTest do
  use ChangelogWeb.ConnCase

  @tag :as_admin
  test "searching news items", %{conn: conn} do
    insert(:published_news_item, headline: "This is a goodie")
    insert(:news_item, headline: "Goodie but not published")

    conn = get(conn, "/admin/search/news_item?q=goodie&f=json")

    assert conn.status == 200
    assert conn.resp_body =~ "This is a goodie"
    refute conn.resp_body =~ "Goodie but not published"
  end

  @tag :as_admin
  test "searching people", %{conn: conn} do
    insert(:person, name: "joe blow", handle: "joeblow", email: "joe@blow.com")
    insert(:person, name: "oh no", handle: "ohnoes", email: "oh@no.com")

    conn = get(conn, "/admin/search/person?q=jo&f=json")

    assert conn.status == 200
    assert conn.resp_body =~ "joe blow"
    refute conn.resp_body =~ "oh no"
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

  @tag :as_admin
  test "searching topics", %{conn: conn} do
    insert(:topic, name: "Elixir Phoenix")
    insert(:topic, name: "Elixir Ecto")

    conn = get(conn, "/admin/search/topic?q=ect&f=json")

    assert conn.status == 200
    assert conn.resp_body =~ "Elixir Ecto"
    refute conn.resp_body =~ "Elixir Phoenix"
  end

  test "requires user auth", %{conn: conn} do
    conn = get(conn, "/admin/search/topic?q=ect&f=json")
    assert html_response(conn, 302)
    assert conn.halted
  end
end
