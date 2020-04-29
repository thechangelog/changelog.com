defmodule ChangelogWeb.NewsSourceControllerTest do
  use ChangelogWeb.ConnCase

  test "getting the index", %{conn: conn} do
    s1 = insert(:news_source)
    s2 = insert(:news_source)
    insert(:news_item, source: s1)
    conn = get(conn, Routes.news_source_path(conn, :index))
    assert conn.status == 200
    assert conn.resp_body =~ s1.name
    refute conn.resp_body =~ s2.name
  end

  test "getting a news source page", %{conn: conn} do
    s = insert(:news_source)
    conn = get(conn, Routes.news_source_path(conn, :show, s.slug))
    assert html_response(conn, 200) =~ s.name
  end
end
