defmodule Changelog.AuthControllerTest do
  use Changelog.ConnCase

  alias Changelog.Person

  def valid_expires_at do
    Timex.Date.now
    |> Timex.Date.add(Timex.Time.to_timestamp(15, :mins))
  end

  def invalid_expires_at do
    Timex.Date.now
    |> Timex.Date.subtract(Timex.Time.to_timestamp(15, :mins))
  end

  test "getting the sign in form" do
    conn = get conn(), "/in"

    assert html_response(conn, 200) =~ "Sign In"
  end

  test "submitting the form with known email sets auth token and sends email" do
    person = insert_person(auth_token: nil)

    conn = post conn(), "/in", auth: %{email: person.email}
    person = Repo.get(Person, person.id)

    assert html_response(conn, 200) =~ "Check your email"
    assert person.auth_token != nil
  end

  test "following a valid auth token signs you in" do
    person = insert_person()

    changeset = Person.auth_changeset(person, %{
      auth_token: "12345",
      auth_token_expires_at: valid_expires_at()
    })

    {:ok, person} = Repo.update(changeset)
    {:ok, encoded} = Person.encoded_auth(person)

    conn = get conn(), "/in/#{encoded}"

    assert redirected_to(conn) == page_path(conn, :index)
    assert get_session(conn, :user_id) == person.id
  end

  test "following an expired auth token doesn't sign you in" do
    person = insert_person()

    changeset = Person.auth_changeset(person, %{
      auth_token: "12345",
      auth_token_expires_at: invalid_expires_at()
    })

    {:ok, person} = Repo.update(changeset)
    {:ok, encoded} = Person.encoded_auth(person)

    conn = get conn(), "/in/#{encoded}"

    assert html_response(conn, 200) =~ "Sign In"
    refute get_session(conn, :user_id) == person.id
  end
end
