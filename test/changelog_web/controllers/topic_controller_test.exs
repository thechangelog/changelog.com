defmodule ChangelogWeb.TopicControllerTest do
  use ChangelogWeb.ConnCase

  test "getting the index", %{conn: conn} do
    t1 = insert(:topic)
    t2 = insert(:topic)
    insert(:news_item_topic, topic: t1)
    conn = get(conn, topic_path(conn, :index))
    assert conn.status == 200
    assert conn.resp_body =~ t1.name
    refute conn.resp_body =~ t2.name
  end

  test "getting a topic all page", %{conn: conn} do
    t = insert(:topic)
    conn = get(conn, topic_path(conn, :show, t.slug))
    assert html_response(conn, 200) =~ t.name
  end

  test "getting a topic's new page", %{conn: conn} do
    topic = insert(:topic)
    news_item = insert(:published_news_item)
    insert(:news_item_topic, topic: topic, news_item: news_item)
    conn = get(conn, topic_path(conn, :news, topic.slug))
    assert conn.status == 200
    assert conn.resp_body =~ topic.name
    assert conn.resp_body =~ news_item.headline
  end
end
