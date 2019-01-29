defmodule ChangelogWeb.Admin.NewsSourceControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.NewsSource

  @valid_attrs %{name: "Wired", slug: "wired", website: "https://wired.com"}
  @invalid_attrs %{name: "Wired", slug: "wired", website: ""}

  @tag :as_admin
  test "lists all news sources", %{conn: conn} do
    news_source = insert(:news_source)

    conn = get(conn, admin_news_source_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/Sources/
    assert String.contains?(conn.resp_body, news_source.name)
  end

  @tag :as_admin
  test "renders form to create new source", %{conn: conn} do
    conn = get(conn, admin_news_source_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/new/
  end

  @tag :as_admin
  test "creates news source and redirects", %{conn: conn} do
    conn = post(conn, admin_news_source_path(conn, :create), news_source: @valid_attrs)

    created = Repo.one(NewsSource.limit(1))
    assert redirected_to(conn) == admin_news_source_path(conn, :edit, created)
    assert count(NewsSource) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(NewsSource)
    conn = post(conn, admin_news_source_path(conn, :create), news_source: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(NewsSource) == count_before
  end

  @tag :as_admin
  test "renders form to edit news source", %{conn: conn} do
    news_source = insert(:news_source)

    conn = get(conn, admin_news_source_path(conn, :edit, news_source))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates news source and redirects", %{conn: conn} do
    news_source = insert(:news_source)
    conn = put(conn, admin_news_source_path(conn, :update, news_source.id), news_source: @valid_attrs)

    assert redirected_to(conn) == admin_news_source_path(conn, :index)
    assert count(NewsSource) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    news_source = insert(:news_source)
    count_before = count(NewsSource)

    conn = put(conn, admin_news_source_path(conn, :update, news_source.id), news_source: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(NewsSource) == count_before
  end

  test "requires user auth on all actions", %{conn: conn} do
    news_source = insert(:news_source)

    Enum.each([
      get(conn, admin_news_source_path(conn, :index)),
      get(conn, admin_news_source_path(conn, :new)),
      post(conn, admin_news_source_path(conn, :create), news_source: @valid_attrs),
      get(conn, admin_news_source_path(conn, :edit, news_source.id)),
      put(conn, admin_news_source_path(conn, :update, news_source.id), news_source: @valid_attrs),
      delete(conn, admin_news_source_path(conn, :delete, news_source.id)),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
