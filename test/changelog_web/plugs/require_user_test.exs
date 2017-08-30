defmodule ChangelogWeb.RequireUserTest do
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

  test "it halts when there is no user assigned", %{conn: conn} do
    conn = Plug.RequireUser.call(conn, [])
    assert conn.halted
  end

  test "it doesnt' halt when there is a user assigned", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Person{})
      |> Plug.RequireUser.call([])

    refute conn.halted
  end
end
