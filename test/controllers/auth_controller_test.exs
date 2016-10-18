defmodule Changelog.AuthControllerTest do
  use Changelog.ConnCase
  use Bamboo.Test

  alias Changelog.Person

  def valid_expires_at do
    Timex.now |> Timex.add(Timex.Duration.from_minutes(15))
  end

  def invalid_expires_at do
    Timex.now |> Timex.subtract(Timex.Duration.from_minutes(15))
  end

  test "getting the sign in form" do
    conn = get(build_conn, "/in")

    assert html_response(conn, 200) =~ "Sign In"
  end

  test "submitting the form with known email sets auth token and sends email" do
    person = insert(:person, auth_token: nil)

    conn = post(build_conn, "/in", auth: %{email: person.email})
    person = Repo.get(Person, person.id)

    assert html_response(conn, 200) =~ "Check your email"
    assert person.auth_token != nil
    assert_delivered_email Changelog.Email.sign_in_email(person)
  end

  test "following a valid auth token signs you in" do
    person = insert(:person)

    changeset = Person.auth_changeset(person, %{
      auth_token: "12345",
      auth_token_expires_at: valid_expires_at()
    })

    {:ok, person} = Repo.update(changeset)
    {:ok, encoded} = Person.encoded_auth(person)

    conn = get(build_conn, "/in/#{encoded}")

    assert redirected_to(conn) == page_path(conn, :home)
    assert get_encrypted_cookie(conn, "_changelog_user") == person.id
  end

  test "following an expired auth token doesn't sign you in" do
    person = insert(:person)

    changeset = Person.auth_changeset(person, %{
      auth_token: "12345",
      auth_token_expires_at: invalid_expires_at()
    })

    {:ok, person} = Repo.update(changeset)
    {:ok, encoded} = Person.encoded_auth(person)

    conn = get(build_conn, "/in/#{encoded}")

    assert html_response(conn, 200) =~ "Sign In"
    refute get_encrypted_cookie(conn, "_changelog_user") == person.id
  end
end
