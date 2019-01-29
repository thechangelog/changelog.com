defmodule ChangelogWeb.Admin.SponsorControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.Sponsor

  @valid_attrs %{name: "Alphabet, Inc."}
  @invalid_attrs %{name: ""}

  @tag :as_admin
  test "lists all sponsors on index", %{conn: conn} do
    s1 = insert(:sponsor)
    s2 = insert(:sponsor)

    conn = get(conn, admin_sponsor_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/Sponsors/
    assert String.contains?(conn.resp_body, s1.name)
    assert String.contains?(conn.resp_body, s2.name)
  end

  @tag :as_admin
  test "renders form to create new sponsor", %{conn: conn} do
    conn = get(conn, admin_sponsor_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/new/
  end

  @tag :as_admin
  test "creates sponsor and redirects", %{conn: conn} do
    conn = post(conn, admin_sponsor_path(conn, :create), sponsor: @valid_attrs, next: admin_sponsor_path(conn, :index))

    assert redirected_to(conn) == admin_sponsor_path(conn, :index)
    assert count(Sponsor) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(Sponsor)
    conn = post(conn, admin_sponsor_path(conn, :create), sponsor: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Sponsor) == count_before
  end

  @tag :as_admin
  test "renders form to edit sponsor", %{conn: conn} do
    sponsor = insert(:sponsor)

    conn = get(conn, admin_sponsor_path(conn, :edit, sponsor))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates sponsor and redirects", %{conn: conn} do
    sponsor = insert(:sponsor)

    conn = put conn, admin_sponsor_path(conn, :update, sponsor.id), sponsor: @valid_attrs

    assert redirected_to(conn) == admin_sponsor_path(conn, :index)
    assert count(Sponsor) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    sponsor = insert(:sponsor)
    count_before = count(Sponsor)

    conn = put conn, admin_sponsor_path(conn, :update, sponsor.id), sponsor: @invalid_attrs

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Sponsor) == count_before
  end

  @tag :as_admin
  test "deletes a sponsor and redirects", %{conn: conn} do
    sponsor = insert(:sponsor)

    conn = delete conn, admin_sponsor_path(conn, :delete, sponsor.id)

    assert redirected_to(conn) == admin_sponsor_path(conn, :index)
    assert count(Sponsor) == 0
  end

  test "requires user auth on all actions", %{conn: conn} do
    sponsor = insert(:sponsor)

    Enum.each([
      get(conn, admin_sponsor_path(conn, :index)),
      get(conn, admin_sponsor_path(conn, :new)),
      post(conn, admin_sponsor_path(conn, :create), sponsor: @valid_attrs),
      get(conn, admin_sponsor_path(conn, :edit, sponsor.id)),
      put(conn, admin_sponsor_path(conn, :update, sponsor.id), sponsor: @valid_attrs),
      delete(conn, admin_sponsor_path(conn, :delete, sponsor.id)),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
