defmodule ChangelogWeb.Admin.SearchControllerTest do
  use ChangelogWeb.ConnCase

  @tag :as_admin
  test "searching all", %{conn: conn} do
    person = insert(:person, name: "Safari Fan")
    episode = insert(:published_episode, title: "Safari Show")
    topic = insert(:topic, name: "Safari")
    news = insert(:published_news_item, headline: "Safari wins")
    sponsor = insert(:sponsor, name: "Safari People")
    post = insert(:post, title: "Safari is cool bc")

    conn = get(conn, "/admin/search/?q=Safari")

    assert conn.status == 200
    assert conn.resp_body =~ person.name
    assert conn.resp_body =~ episode.title
    assert conn.resp_body =~ topic.name
    assert conn.resp_body =~ news.headline
    assert conn.resp_body =~ sponsor.name
    assert conn.resp_body =~ post.title
  end

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
