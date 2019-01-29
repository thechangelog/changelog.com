defmodule ChangelogWeb.Admin.BenefitControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.Benefit

  @valid_attrs %{offer: "Free stuff!", sponsor_id: 1}
  @invalid_attrs %{offer: ""}

  @tag :as_admin
  test "lists all benefits on index", %{conn: conn} do
    b1 = insert(:benefit)
    b2 = insert(:benefit)

    conn = get(conn, admin_benefit_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/Benefits/
    assert String.contains?(conn.resp_body, b1.offer)
    assert String.contains?(conn.resp_body, b2.offer)
  end

  @tag :as_admin
  test "renders form to create new benefit", %{conn: conn} do
    conn = get(conn, admin_benefit_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/new/
  end

  @tag :as_admin
  test "creates benefit and redirects", %{conn: conn} do
    sponsor = insert(:sponsor)

    conn = post(conn, admin_benefit_path(conn, :create), benefit: %{@valid_attrs | sponsor_id: sponsor.id}, next: admin_benefit_path(conn, :index))

    assert redirected_to(conn) == admin_benefit_path(conn, :index)
    assert count(Benefit) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(Benefit)
    conn = post(conn, admin_benefit_path(conn, :create), benefit: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Benefit) == count_before
  end

  @tag :as_admin
  test "renders form to edit benefit", %{conn: conn} do
    benefit = insert(:benefit)

    conn = get(conn, admin_benefit_path(conn, :edit, benefit))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates benefit and redirects", %{conn: conn} do
    sponsor = insert(:sponsor)
    benefit = insert(:benefit, sponsor: sponsor)

    conn = put(conn, admin_benefit_path(conn, :update, benefit.id), benefit: %{@valid_attrs | sponsor_id: sponsor.id})

    assert redirected_to(conn) == admin_benefit_path(conn, :index)
    assert count(Benefit) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    benefit = insert(:benefit)
    count_before = count(Benefit)

    conn = put(conn, admin_benefit_path(conn, :update, benefit.id), benefit: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Benefit) == count_before
  end

  @tag :as_admin
  test "deletes a benefit and redirects", %{conn: conn} do
    benefit = insert(:benefit)

    conn = delete(conn, admin_benefit_path(conn, :delete, benefit.id))

    assert redirected_to(conn) == admin_benefit_path(conn, :index)
    assert count(Benefit) == 0
  end

  test "requires user auth on all actions", %{conn: conn} do
    benefit = insert(:benefit)

    Enum.each([
      get(conn, admin_benefit_path(conn, :index)),
      get(conn, admin_benefit_path(conn, :new)),
      post(conn, admin_benefit_path(conn, :create), benefit: @valid_attrs),
      get(conn, admin_benefit_path(conn, :edit, benefit.id)),
      put(conn, admin_benefit_path(conn, :update, benefit.id), benefit: @valid_attrs),
      delete(conn, admin_benefit_path(conn, :delete, benefit.id)),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
