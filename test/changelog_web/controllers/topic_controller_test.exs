defmodule ChangelogWeb.TopicControllerTest do
  use ChangelogWeb.ConnCase

  test "getting the index", %{conn: conn} do
    t1 = insert(:topic)
    t2 = insert(:topic)
    conn = get(conn, topic_path(conn, :index))
    assert conn.status == 200
    assert conn.resp_body =~ t1.name
    assert conn.resp_body =~ t2.name
  end

  test "getting a topic page", %{conn: conn} do
    t = insert(:topic)
    conn = get(conn, topic_path(conn, :show, t.slug))
    assert html_response(conn, 200) =~ t.name
  end
end
