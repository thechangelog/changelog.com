defmodule Changelog.HomeControllerTest do
  use Changelog.ConnCase

  @tag :as_user
  test "the home page renders", %{conn: conn, user: user} do
    conn = get(conn, home_path(conn, :show))
    assert html_response(conn, 200) =~ user.handle
  end

  test "requires user on all actions", %{conn: conn} do
    Enum.each([
      get(conn, home_path(conn, :show)),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
