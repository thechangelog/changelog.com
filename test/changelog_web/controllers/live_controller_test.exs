defmodule ChangelogWeb.LiveControllerTest do
  use ChangelogWeb.ConnCase

  test "getting a live episode page", %{conn: conn} do
    conn = get(conn, ~p"/live/8675309")

    assert_redirected_to(conn, ~p"/live")
  end

  test "getting ical sans podcast slug", %{conn: conn} do
    conn = get(conn, ~p"/live/ical")

    assert conn.status == 410
    assert conn.resp_body =~ "discontinued"
  end

  test "getting ical with podcast slug", %{conn: conn} do
    conn = get(conn, ~p"/live/ical/8675309")

    assert conn.status == 410
    assert conn.resp_body =~ "discontinued"
  end
end
