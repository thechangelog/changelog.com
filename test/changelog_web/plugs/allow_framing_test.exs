defmodule ChangelogWeb.AllowFramingTest do
  use ChangelogWeb.ConnCase

  alias ChangelogWeb.{Plug, Router}

  setup _config do
    conn = bypass_through(build_conn(), Router, :browser)

    {:ok, %{conn: conn}}
  end

  test "deletes frame options header on embeds", %{conn: conn} do
    conn =
      conn
      |> get("/founderstalk/62/embed")
      |> Plug.AllowFraming.call([])

    assert get_resp_header(conn, "x-frame-options") == []
  end

  test "does not delete frame options header on other requests", %{conn: conn} do
    conn =
      conn
      |> get("/founderstalk/62")
      |> Plug.AllowFraming.call([])

    assert get_resp_header(conn, "x-frame-options") == ["SAMEORIGIN"]
  end
end
