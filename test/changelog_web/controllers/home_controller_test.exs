defmodule ChangelogWeb.HomeControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.Person

  @tag :as_user
  test "renders the home page", %{conn: conn} do
    conn = get(conn, home_path(conn, :show))
    assert html_response(conn, 200)
  end

  @tag :as_user
  test "renders the account form", %{conn: conn} do
    conn = get(conn, home_path(conn, :account))
    assert html_response(conn, 200) =~ "form"
  end

  @tag :as_user
  test "renders the profile form", %{conn: conn} do
    conn = get(conn, home_path(conn, :profile))
    assert html_response(conn, 200) =~ "form"
  end

  @tag :as_inserted_user
  test "updates person and redirects to home page", %{conn: conn} do
    conn = put(conn, home_path(conn, :update), from: "account", person: %{name: "New Name"})

    assert redirected_to(conn) == home_path(conn, :show)
  end

  @tag :as_inserted_user
  test "does not update with invalid attributes", %{conn: conn} do
    conn = put(conn, home_path(conn, :update), from: "profile", person: %{name: ""})
    assert html_response(conn, 200) =~ ~r/problem/
  end

  test "opting out of notifications", %{conn: conn} do
    person = insert(:person)
    {:ok, token} = Person.encoded_id(person)
    conn = get(conn, home_path(conn, :opt_out, token, "email_on_authored_news"))
    assert conn.status == 200
    refute Repo.get(Person, person.id).settings.email_on_authored_news
  end

  @tag :as_inserted_user
  test "signed in and opting out of notifications", %{conn: conn} do
    person = conn.assigns.current_user
    {:ok, token} = Person.encoded_id(person)
    conn = get(conn, home_path(conn, :opt_out, token, "email_on_submitted_news"))
    assert conn.status == 200
    refute Repo.get(Person, person.id).settings.email_on_submitted_news
  end

  test "requires user on all actions except email links", %{conn: conn} do
    Enum.each([
      get(conn, home_path(conn, :show)),
      get(conn, home_path(conn, :profile)),
      get(conn, home_path(conn, :account)),
      put(conn, home_path(conn, :update), person: %{}),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
