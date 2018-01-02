defmodule ChangelogWeb.NewsItemControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.Hashid
  alias ChangelogWeb.NewsItemView

  test "getting the index", %{conn: conn} do
    i1 = insert(:news_item)
    i2 = insert(:published_news_item)

    conn = get(conn, root_path(conn, :index))

    assert conn.status == 200
    refute conn.resp_body =~ i1.headline
    assert conn.resp_body =~ i2.headline
  end

  test "getting a published news item page via hashid", %{conn: conn} do
    item = insert(:published_news_item, headline: "Hash ID me!")
    hashid = Hashid.encode(item.id)
    conn = get(conn, news_item_path(conn, :show, hashid))
    assert redirected_to(conn) == news_item_path(conn, :show, NewsItemView.slug(item))
  end

  test "getting a published news item page via full slug", %{conn: conn} do
    item = insert(:published_news_item, headline: "You gonna like this")
    conn = get(conn, news_item_path(conn, :show, NewsItemView.slug(item)))
    assert html_response(conn, 200) =~ item.headline
  end

  test "getting an unpublished news item page", %{conn: conn} do
    item = insert(:news_item)

    assert_raise Ecto.NoResultsError, fn ->
      get(conn, news_item_path(conn, :show, NewsItemView.slug(item)))
    end
  end

  test "geting a news item page that doesn't exist", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get(conn, news_item_path(conn, :show, "bad-news_item"))
    end
  end

  test "previewing a news item when not an admin", %{conn: conn} do
    item = insert(:news_item)

    conn = get(conn, news_item_path(conn, :preview, item))
    assert conn.halted
  end

  @tag :as_admin
  test "previewing a news item when signed in as admin", %{conn: conn} do
    item = insert(:news_item)

    conn = get(conn, news_item_path(conn, :preview, item))
    assert html_response(conn, 200) =~ item.headline
  end
end
