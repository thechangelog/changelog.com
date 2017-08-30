defmodule ChangelogWeb.RequireAdminTest do
  use ChangelogWeb.ConnCase

  alias Changelog.Person
  alias ChangelogWeb.{Plug, Router}

  setup _config do
    conn =
      build_conn()
      |> bypass_through(Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "it halts when no user is assigned", %{conn: conn} do
    conn = Plug.RequireAdmin.call(conn, [])
    assert conn.halted
  end

  test "it halts when assigned user is not an admin", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Person{})
      |> Plug.RequireAdmin.call([])

    assert conn.halted
  end

  test "it doesn't halt when assigned user is an admin", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Person{admin: true})
      |> Plug.RequireAdmin.call([])

    refute conn.halted
  end
end
