defmodule Changelog.RequireGuestTest do
  use Changelog.ConnCase

  setup _config do
    conn =
      build_conn()
      |> bypass_through(Changelog.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "it halts when there is a user assigned", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Changelog.Person{})
      |> Changelog.Plug.RequireGuest.call([])

    assert conn.halted
  end

  test "it doesnt' halt when there is no user assigned", %{conn: conn} do
    conn = Changelog.Plug.RequireGuest.call(conn, [])
    refute conn.halted
  end
end
