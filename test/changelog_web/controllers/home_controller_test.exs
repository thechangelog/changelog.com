defmodule ChangelogWeb.HomeControllerTest do
  use ChangelogWeb.ConnCase

  @tag :as_user
  test "renders the home page", %{conn: conn} do
    conn = get(conn, home_path(conn, :show))
    assert html_response(conn, 200)
  end

  @tag :as_user
  test "renders the edit form", %{conn: conn} do
    conn = get(conn, home_path(conn, :edit))
    assert html_response(conn, 200) =~ "form"
  end

  @tag :as_inserted_user
  test "updates person and redirects to home page", %{conn: conn} do
    conn = put(conn, home_path(conn, :update), person: %{name: "New Name"})

    assert redirected_to(conn) == home_path(conn, :show)
  end

  test "requires user on all actions", %{conn: conn} do
    Enum.each([
      get(conn, home_path(conn, :show)),
      get(conn, home_path(conn, :edit)),
      put(conn, home_path(conn, :update), person: %{}),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
