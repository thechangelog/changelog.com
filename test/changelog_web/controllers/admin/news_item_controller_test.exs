defmodule ChangelogWeb.Admin.NewsItemControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.NewsItem

  @valid_attrs %{type: :project, headline: "Ruby on Rails", url: "https://rubyonrails.org", author_id: 1}
  @invalid_attrs %{type: :project, headline: "Ruby on Rails", url: ""}

  @tag :as_admin
  test "lists all published news items", %{conn: conn} do
    i1 = insert(:published_news_item)
    i2 = insert(:news_item)

    conn = get(conn, admin_news_item_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/News/
    assert String.contains?(conn.resp_body, i1.headline)
    refute String.contains?(conn.resp_body, i2.headline)
  end

  @tag :as_admin
  test "renders form to create new item", %{conn: conn} do
    conn = get(conn, admin_news_item_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/new/
  end

  @tag :as_admin
  test "creates news item and smart redirects", %{conn: conn} do
    author = insert(:person)
    conn = post(conn, admin_news_item_path(conn, :create), news_item: %{@valid_attrs | author_id: author.id}, close: true)

    assert redirected_to(conn) == admin_news_item_path(conn, :index)
    assert count(NewsItem) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(NewsItem)
    conn = post(conn, admin_news_item_path(conn, :create), news_item: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(NewsItem) == count_before
  end

  @tag :as_admin
  test "renders form to edit news item", %{conn: conn} do
    news_item = insert(:news_item)

    conn = get(conn, admin_news_item_path(conn, :edit, news_item))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates news item and smart redirects", %{conn: conn} do
    author = insert(:person)
    news_item = insert(:news_item, author: author)

    conn = put(conn, admin_news_item_path(conn, :update, news_item.id), news_item: %{@valid_attrs | author_id: author.id})

    assert redirected_to(conn) == admin_news_item_path(conn, :edit, news_item)
    assert count(NewsItem) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    news_item = insert(:news_item)
    count_before = count(NewsItem)

    conn = put(conn, admin_news_item_path(conn, :update, news_item.id), news_item: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(NewsItem) == count_before
  end

  test "requires user auth on all actions", %{conn: conn} do
    Enum.each([
      get(conn, admin_news_item_path(conn, :index)),
      get(conn, admin_news_item_path(conn, :new)),
      post(conn, admin_news_item_path(conn, :create), news_item: @valid_attrs),
      get(conn, admin_news_item_path(conn, :edit, "123")),
      put(conn, admin_news_item_path(conn, :update, "123"), news_item: @valid_attrs),
      delete(conn, admin_news_item_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
