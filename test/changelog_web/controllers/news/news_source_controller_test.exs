defmodule ChangelogWeb.NewsSourceControllerTest do
  use ChangelogWeb.ConnCase

  test "getting a news source page", %{conn: conn} do
    s = insert(:news_source)
    conn = get(conn, news_source_path(conn, :show, s.slug))
    assert html_response(conn, 200) =~ s.name
  end
end
