defmodule ChangelogWeb.NewsItemControllerTest do
  use ChangelogWeb.ConnCase

  import ChangelogWeb.NewsItemView, only: [hashid: 1, slug: 1]

  alias Changelog.NewsItem

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
    hashid = hashid(item)
    conn = get(conn, news_item_path(conn, :show, hashid))
    assert redirected_to(conn) == news_item_path(conn, :show, slug(item))
  end

  test "getting a published news item page via full slug", %{conn: conn} do
    item = insert(:published_news_item, headline: "You gonna like this")
    conn = get(conn, news_item_path(conn, :show, slug(item)))
    assert html_response(conn, 200) =~ item.headline
  end

  test "getting an unpublished news item page", %{conn: conn} do
    item = insert(:news_item)

    assert_raise Ecto.NoResultsError, fn ->
      get(conn, news_item_path(conn, :show, slug(item)))
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

  test "hitting the visit endpoint", %{conn: conn} do
    item = insert(:published_news_item, headline: "You gonna like this")
    conn = get(conn, news_item_path(conn, :visit, hashid(item)))
    assert redirected_to(conn) == item.url
    item = Repo.get(NewsItem, item.id)
    assert item.click_count == 1
  end

  test "hitting the impress endpoint", %{conn: conn} do
    item1 = insert(:published_news_item, headline: "You gonna like this")
    item2 = insert(:published_news_item, headline: "You gonna like this too")
    conn = post(conn, news_item_path(conn, :impress), items: "#{hashid(item1)},#{hashid(item2)}")
    assert conn.status == 200
    item1 = Repo.get(NewsItem, item1.id)
    item2 = Repo.get(NewsItem, item2.id)
    assert item1.impression_count == 1
    assert item2.impression_count == 1
  end
end
