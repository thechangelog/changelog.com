defmodule ChangelogWeb.Admin.MetacastControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.Metacast
  alias ChangelogWeb.Router.Helpers

  @valid_attrs %{name: "Polyglot", filter_query: "except"}
  @invalid_attrs %{name: ""}

  defp valid_attrs(slug), do: Map.put(@valid_attrs, :slug, slug)

  @tag :as_admin
  test "lists all metacasts", %{conn: conn} do
    p1 = insert(:metacast, slug: "list-all-1")
    p2 = insert(:metacast, slug: "list-all-2")

    conn = get(conn, Helpers.admin_metacast_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/Metacasts/
    assert String.contains?(conn.resp_body, p1.name)
    assert String.contains?(conn.resp_body, p2.name)
  end

  @tag :as_admin
  test "renders form to create new metacast", %{conn: conn} do
    conn = get(conn, Helpers.admin_metacast_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/new/
  end

  @tag :as_admin
  test "creates metacast and redirects", %{conn: conn} do
    conn = post(conn, Helpers.admin_metacast_path(conn, :create), metacast: valid_attrs("creates-metacast-and-redirects"), next: Helpers.admin_metacast_path(conn, :index))

    assert redirected_to(conn) == Helpers.admin_metacast_path(conn, :index)
    assert count(Metacast) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(Metacast)
    conn = post(conn, Helpers.admin_metacast_path(conn, :create), metacast: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Metacast) == count_before
  end

  @tag :as_admin
  test "renders form to edit metacast", %{conn: conn} do
    metacast = insert(:metacast, slug: "render-form-to-edit-metacast")

    conn = get(conn, Helpers.admin_metacast_path(conn, :edit, metacast))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates metacast and redirects", %{conn: conn} do
    metacast = insert(:metacast, slug: "updates-metacast-and-redirects")

    conn = put(conn, Helpers.admin_metacast_path(conn, :update, metacast), metacast: valid_attrs("updates-metacast-and-redirects"))

    assert redirected_to(conn) == Helpers.admin_metacast_path(conn, :index)
    assert count(Metacast) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    metacast = insert(:metacast, slug: "does-not-update-with-invalid-attributes")
    count_before = count(Metacast)

    conn = put(conn, Helpers.admin_metacast_path(conn, :update, metacast), metacast: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Metacast) == count_before
  end

  test "requires user auth on all actions", %{conn: conn} do
    metacast = insert(:metacast, slug: "requires-user-auth-on-all-actions")

    Enum.each([
      get(conn, Helpers.admin_metacast_path(conn, :index)),
      get(conn, Helpers.admin_metacast_path(conn, :new)),
      post(conn, Helpers.admin_metacast_path(conn, :create), metacast: valid_attrs("requires-user-auth-1")),
      get(conn, Helpers.admin_metacast_path(conn, :edit, metacast)),
      put(conn, Helpers.admin_metacast_path(conn, :update, metacast), metacast: valid_attrs("requires-user-auth-2"))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end