defmodule ChangelogWeb.Admin.PersonControllerTest do
  use ChangelogWeb.ConnCase
  use Bamboo.Test

  import Mock

  alias Changelog.Person

  @valid_attrs %{name: "Joe Blow", email: "joe@blow.com", handle: "joeblow"}
  @invalid_attrs %{name: "", email: "noname@nope.com"}

  @tag :as_admin
  test "lists all people on index", %{conn: conn} do
    p1 = insert(:person)
    p2 = insert(:person)

    conn = get(conn, admin_person_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/People/
    assert String.contains?(conn.resp_body, p1.name)
    assert String.contains?(conn.resp_body, p2.name)
  end

  @tag :as_admin
  test "renders form to create new person", %{conn: conn} do
    conn = get(conn, admin_person_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/new/
  end

  @tag :as_admin
  test "creates person, sends no welcome, and smart redirects", %{conn: conn} do
    conn = with_mock Craisin.Subscriber, [subscribe: fn(_, _, _) -> nil end] do
      post(conn, admin_person_path(conn, :create), person: @valid_attrs, close: true)
    end

    Repo.one(from p in Person, where: p.email == ^@valid_attrs[:email])
    assert_no_emails_delivered()
    assert redirected_to(conn) == admin_person_path(conn, :index)
    assert count(Person) == 1
  end

  @tag :as_admin
  test "creates person, sends generic welcome, and smart redirects", %{conn: conn} do
    conn = with_mock Craisin.Subscriber, [subscribe: fn(_, _, _) -> nil end] do
      post(conn, admin_person_path(conn, :create), person: @valid_attrs, close: true, welcome: "generic")
    end

    person = Repo.one(from p in Person, where: p.email == ^@valid_attrs[:email])
    assert_delivered_email ChangelogWeb.Email.welcome(person)
    assert redirected_to(conn) == admin_person_path(conn, :index)
    assert count(Person) == 1
  end

  @tag :as_admin
  test "creates person, sends guest welcome, and smart redirects", %{conn: conn} do
    conn = with_mock Craisin.Subscriber, [subscribe: fn(_, _, _) -> nil end] do
      post(conn, admin_person_path(conn, :create), person: @valid_attrs, close: true, welcome: "guest")
    end

    person = Repo.one(from p in Person, where: p.email == ^@valid_attrs[:email])
    assert_delivered_email ChangelogWeb.Email.guest_welcome(person)
    assert redirected_to(conn) == admin_person_path(conn, :index)
    assert count(Person) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(Person)
    conn = post(conn, admin_person_path(conn, :create), person: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Person) == count_before
  end

  @tag :as_admin
  test "renders form to edit person", %{conn: conn} do
    person = insert(:person)

    conn = get(conn, admin_person_path(conn, :edit, person))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates person and smart redirects", %{conn: conn} do
    person = insert(:person)

    conn = put conn, admin_person_path(conn, :update, person.id), person: @valid_attrs

    assert redirected_to(conn) == admin_person_path(conn, :edit, person)
    assert count(Person) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    person = insert(:person)
    count_before = count(Person)

    conn = put conn, admin_person_path(conn, :update, person.id), person: @invalid_attrs

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Person) == count_before
  end

  @tag :as_admin
  test "deletes a person and redirects", %{conn: conn} do
    person = insert(:person)

    conn = delete conn, admin_person_path(conn, :delete, person.id)

    assert redirected_to(conn) == admin_person_path(conn, :index)
    assert count(Person) == 0
  end

  test "requires user auth on all actions", %{conn: conn} do
    Enum.each([
      get(conn, admin_person_path(conn, :index)),
      get(conn, admin_person_path(conn, :new)),
      post(conn, admin_person_path(conn, :create), person: @valid_attrs),
      get(conn, admin_person_path(conn, :edit, "123")),
      put(conn, admin_person_path(conn, :update, "123"), person: @valid_attrs),
      delete(conn, admin_person_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
