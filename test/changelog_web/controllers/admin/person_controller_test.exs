defmodule ChangelogWeb.Admin.PersonControllerTest do
  use ChangelogWeb.ConnCase
  use Changelog.EmailCase
  use Oban.Testing, repo: Changelog.Repo

  import Mock

  alias Changelog.{Person, Slack, Zulip}

  @valid_attrs %{name: "Joe Blow", email: "joe@blow.com", handle: "joeblow"}
  @invalid_attrs %{name: "", email: "noname@nope.com"}

  @tag :as_admin
  test "lists all people on index", %{conn: conn} do
    p1 = insert(:person)
    p2 = insert(:person)

    conn = get(conn, Routes.admin_person_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/People/
    assert String.contains?(conn.resp_body, p1.name)
    assert String.contains?(conn.resp_body, p2.name)
  end

  @tag :as_admin
  test "shows a specific person", %{conn: conn} do
    p1 = insert(:person)

    conn = get(conn, Routes.admin_person_path(conn, :show, p1))

    assert html_response(conn, 200) =~ p1.name
  end

  @tag :as_admin
  test "renders form to create new person", %{conn: conn} do
    conn = get(conn, Routes.admin_person_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/new/
  end

  @tag :as_admin
  test "creates person, sends no welcome, and redirects", %{conn: conn} do
    conn = post(conn, Routes.admin_person_path(conn, :create), person: @valid_attrs, close: true)

    person = Repo.one(from p in Person, where: p.email == ^@valid_attrs[:email])
    assert_no_email_sent()
    assert redirected_to(conn) == Routes.admin_person_path(conn, :edit, person)
    assert count(Person) == 1
  end

  @tag :as_admin
  test "creates person, sends generic welcome, and redirects", %{conn: conn} do
    conn =
      post(conn, Routes.admin_person_path(conn, :create),
        person: @valid_attrs,
        welcome: "generic",
        next: Routes.admin_person_path(conn, :index)
      )

    assert %{success: 1, failure: 0} = Oban.drain_queue(queue: :email)

    person = Repo.one(from p in Person, where: p.email == ^@valid_attrs[:email])
    assert_email_sent(ChangelogWeb.Email.community_welcome(person))
    assert redirected_to(conn) == Routes.admin_person_path(conn, :index)
    assert count(Person) == 1
  end

  @tag :as_admin
  test "creates person, sends guest welcome, and redirects", %{conn: conn} do
    conn =
      post(conn, Routes.admin_person_path(conn, :create), person: @valid_attrs, welcome: "guest")

    assert %{success: 1, failure: 0} = Oban.drain_queue(queue: :email)

    person = Repo.one(from p in Person, where: p.email == ^@valid_attrs[:email])
    assert_email_sent(ChangelogWeb.Email.guest_welcome(person))
    assert redirected_to(conn) == Routes.admin_person_path(conn, :edit, person)
    assert count(Person) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(Person)
    conn = post(conn, Routes.admin_person_path(conn, :create), person: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Person) == count_before
  end

  @tag :as_admin
  test "renders form to edit person", %{conn: conn} do
    person = insert(:person)

    conn = get(conn, Routes.admin_person_path(conn, :edit, person))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates person and redirects", %{conn: conn} do
    person = insert(:person)

    conn = put(conn, Routes.admin_person_path(conn, :update, person.id), person: @valid_attrs)

    assert redirected_to(conn) == Routes.admin_person_path(conn, :index)
    assert count(Person) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    person = insert(:person)
    count_before = count(Person)

    conn = put(conn, Routes.admin_person_path(conn, :update, person.id), person: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Person) == count_before
  end

  @tag :as_admin
  test "deletes a person and redirects", %{conn: conn} do
    person = insert(:person)

    with_mock(Craisin.Subscriber, delete: fn _, _ -> true end) do
      conn = delete(conn, Routes.admin_person_path(conn, :delete, person.id))

      assert redirected_to(conn) == Routes.admin_person_path(conn, :index)
      assert count(Person) == 0
      assert called(Craisin.Subscriber.delete(:_, person.email))
    end
  end

  @tag :as_admin
  test "invites to slack", %{conn: conn} do
    person = insert(:person)

    with_mock(Slack.Client, invite: fn _ -> %{"ok" => true} end) do
      conn = post(conn, Routes.admin_person_path(conn, :slack, person))

      assert redirected_to(conn) == Routes.admin_person_path(conn, :index)
      assert called(Slack.Client.invite(person.email))
    end
  end

  @tag :as_admin
  test "invites to zulip", %{conn: conn} do
    person = insert(:person)

    with_mock(Zulip, invite: fn _ -> %{"ok" => true} end) do
      conn = post(conn, ~p"/admin/people/#{person.id}/zulip")

      assert redirected_to(conn) == ~p"/admin/people"
      assert called(Zulip.invite(:_))
    end
  end

  test "requires user auth on all actions", %{conn: conn} do
    person = insert(:person)

    Enum.each(
      [
        get(conn, Routes.admin_person_path(conn, :index)),
        get(conn, Routes.admin_person_path(conn, :new)),
        post(conn, Routes.admin_person_path(conn, :create), person: @valid_attrs),
        get(conn, Routes.admin_person_path(conn, :edit, person.id)),
        put(conn, Routes.admin_person_path(conn, :update, person.id), person: @valid_attrs),
        delete(conn, Routes.admin_person_path(conn, :delete, person.id)),
        get(conn, Routes.admin_person_path(conn, :news, person.id)),
        get(conn, Routes.admin_person_path(conn, :comments, person.id))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end
end
