defmodule Changelog.RequireAdminTest do
  use Changelog.ConnCase

  setup _config do
    conn =
      build_conn()
      |> bypass_through(Changelog.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "it halts when no user is assigned", %{conn: conn} do
    conn = Changelog.Plug.RequireAdmin.call(conn, [])
    assert conn.halted
  end

  test "it halts when assigned user is not an admin", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Changelog.Person{})
      |> Changelog.Plug.RequireAdmin.call([])

    assert conn.halted
  end

  test "it doesn't halt when assigned user is an admin", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Changelog.Person{admin: true})
      |> Changelog.Plug.RequireAdmin.call([])

    refute conn.halted
  end
end
