defmodule Changelog.PersonControllerTest do
  use Changelog.ConnCase
  use Bamboo.Test

  alias Changelog.Person

  test "getting new person form", %{conn: conn} do
    conn = get(conn, person_path(conn, :new))

    assert conn.status == 200
    assert conn.resp_body =~ "form"
  end

  @tag :as_user
  test "getting new person form when signed in is not allowed", %{conn: conn} do
    conn = get(conn, person_path(conn, :new))
    assert html_response(conn, 302)
    assert conn.halted
  end

  test "submission with missing data re-renders with errors", %{conn: conn} do
    count_before = count(Person)
    conn = post(conn, person_path(conn, :create), person: %{email: "nope"})
    assert html_response(conn, 200) =~ ~r/wrong/i
    assert count(Person) == count_before
  end

  test "submission with required data creates person, sends email, and re-renders", %{conn: conn} do
    count_before = count(Person)

    conn = post(conn, person_path(conn, :create), person: %{email: "joe@blow.com", name: "Joe Blow", handle: "joeblow"})
    person = Repo.one(from p in Person, where: p.email == "joe@blow.com")
    assert_delivered_email Changelog.Email.welcome_email(person)
    assert html_response(conn, 200) =~ ~r/check your email/i
    assert count(Person) == count_before + 1
  end

  test "submission with existing email sends email, re-renders, but doesn't create new person", %{conn: conn} do
    existing = insert(:person)
    count_before = count(Person)

    conn = post(conn, person_path(conn, :create), person: %{email: existing.email, name: "Joe Blow", handle: "joeblow"})
    existing = Repo.one(from p in Person, where: p.email == ^existing.email)

    assert_delivered_email Changelog.Email.welcome_email(existing)
    assert html_response(conn, 200) =~ ~r/check your email/i
    assert count(Person) == count_before
  end
end
