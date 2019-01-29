defmodule ChangelogWeb.Admin.PersonControllerTest do
  use ChangelogWeb.ConnCase
  use Bamboo.Test

  import Mock

  alias Changelog.{Person, Slack}

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
  test "shows a specific person", %{conn: conn} do
    p1 = insert(:person)

    conn = get(conn, admin_person_path(conn, :show, p1))

    assert html_response(conn, 200) =~ p1.name
  end

  @tag :as_admin
  test "renders form to create new person", %{conn: conn} do
    conn = get(conn, admin_person_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/new/
  end

  @tag :as_admin
  test "creates person, sends no welcome, and redirects", %{conn: conn} do
    conn = post(conn, admin_person_path(conn, :create), person: @valid_attrs, close: true)

    person = Repo.one(from p in Person, where: p.email == ^@valid_attrs[:email])
    assert_no_emails_delivered()
    assert redirected_to(conn) == admin_person_path(conn, :edit, person)
    assert count(Person) == 1
  end

  @tag :as_admin
  test "creates person, sends generic welcome, and redirects", %{conn: conn} do
    conn = post(conn, admin_person_path(conn, :create), person: @valid_attrs, welcome: "generic", next: admin_person_path(conn, :index))

    person = Repo.one(from p in Person, where: p.email == ^@valid_attrs[:email])
    assert_delivered_email ChangelogWeb.Email.community_welcome(person)
    assert redirected_to(conn) == admin_person_path(conn, :index)
    assert count(Person) == 1
  end

  @tag :as_admin
  test "creates person, sends guest welcome, and redirects", %{conn: conn} do
    conn = post(conn, admin_person_path(conn, :create), person: @valid_attrs, welcome: "guest")

    person = Repo.one(from p in Person, where: p.email == ^@valid_attrs[:email])
    assert_delivered_email ChangelogWeb.Email.guest_welcome(person)
    assert redirected_to(conn) == admin_person_path(conn, :edit, person)
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
  test "updates person and redirects", %{conn: conn} do
    person = insert(:person)

    conn = put(conn, admin_person_path(conn, :update, person.id), person: @valid_attrs)

    assert redirected_to(conn) == admin_person_path(conn, :index)
    assert count(Person) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    person = insert(:person)
    count_before = count(Person)

    conn = put(conn, admin_person_path(conn, :update, person.id), person: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Person) == count_before
  end

  @tag :as_admin
  test "deletes a person and redirects", %{conn: conn} do
    person = insert(:person)

    conn = delete(conn, admin_person_path(conn, :delete, person.id))
    assert redirected_to(conn) == admin_person_path(conn, :index)
    assert count(Person) == 0
  end

  @tag :as_admin
  test "invites to slack", %{conn: conn} do
    person = insert(:person)

    with_mock(Slack.Client, [invite: fn(_) -> %{"ok" => true} end]) do
      conn = post(conn, admin_person_path(conn, :slack, person))

      assert redirected_to(conn) == admin_person_path(conn, :index)
      assert called Slack.Client.invite(person.email)
    end
  end

  test "requires user auth on all actions", %{conn: conn} do
    person = insert(:person)

    Enum.each([
      get(conn, admin_person_path(conn, :index)),
      get(conn, admin_person_path(conn, :new)),
      post(conn, admin_person_path(conn, :create), person: @valid_attrs),
      get(conn, admin_person_path(conn, :edit, person.id)),
      put(conn, admin_person_path(conn, :update, person.id), person: @valid_attrs),
      delete(conn, admin_person_path(conn, :delete, person.id)),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
