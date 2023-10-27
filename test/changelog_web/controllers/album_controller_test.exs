defmodule ChangelogWeb.AlbumControllerTest do
  use ChangelogWeb.ConnCase

  test "getting the albums index", %{conn: conn} do
    conn = get(conn, ~p"/beats")

    assert conn.status == 200

    for album <- Changelog.Album.all() do
      assert conn.resp_body =~ album.name
    end
  end

  test "getting an album page", %{conn: conn} do
    conn = get(conn, ~p"/beats/theme-songs")
    assert html_response(conn, 200) =~ "Theme Songs"
  end
end
