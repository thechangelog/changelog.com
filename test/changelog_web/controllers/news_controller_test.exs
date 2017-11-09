defmodule ChangelogWeb.NewsControllerTest do
  use ChangelogWeb.ConnCase

  test "getting the index", %{conn: conn} do
    i1 = insert(:news_item)
    i2 = insert(:published_news_item)

    conn = get(conn, root_path(conn, :index))

    assert conn.status == 200
    refute conn.resp_body =~ i1.headline
    assert conn.resp_body =~ i2.headline
  end

  test "getting a published item's page", %{conn: conn} do
    item = insert(:published_news_item, story: "🚨")

    conn = get(conn, news_path(conn, :show, item.id))
    assert html_response(conn, 200) =~ item.story
  end
end
