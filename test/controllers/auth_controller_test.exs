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

  test "getting the sign in form", %{conn: conn} do
    conn = get(conn, "/in")

    assert html_response(conn, 200) =~ "Sign In"
  end

  test "submitting the form with known email sets auth token and sends email", %{conn: conn} do
    person = insert(:person, auth_token: nil)

    conn = post(conn, "/in", auth: %{email: person.email})
    person = Repo.get(Person, person.id)

    assert html_response(conn, 200) =~ "Check your email"
    assert person.auth_token != nil
    assert_delivered_email Changelog.Email.sign_in_email(person)
  end

  test "following a valid auth token signs you in", %{conn: conn} do
    person = insert(:person)

    changeset = Person.auth_changeset(person, %{
      auth_token: "12345",
      auth_token_expires_at: valid_expires_at()
    })

    {:ok, person} = Repo.update(changeset)
    {:ok, encoded} = Person.encoded_auth(person)

    conn = get(conn, "/in/#{encoded}")

    assert redirected_to(conn) == page_path(conn, :home)
    assert get_encrypted_cookie(conn, "_changelog_user") == person.id
  end

  test "following an expired auth token doesn't sign you in", %{conn: conn} do
    person = insert(:person)

    changeset = Person.auth_changeset(person, %{
      auth_token: "12345",
      auth_token_expires_at: invalid_expires_at()
    })

    {:ok, person} = Repo.update(changeset)
    {:ok, encoded} = Person.encoded_auth(person)

    conn = get(conn, "/in/#{encoded}")

    assert html_response(conn, 200) =~ "Sign In"
    refute get_encrypted_cookie(conn, "_changelog_user") == person.id
  end

  test "successful github auth on existing person signs you in", %{conn: conn} do
    person = insert(:person, github_handle: "joeblow")

    conn =
      conn
      |> assign(:ueberauth_auth, %{provider: :github, info: %{nickname: "joeblow"}})
      |> get("/auth/github/callback")

    assert redirected_to(conn) == page_path(conn, :home)
    assert get_encrypted_cookie(conn, "_changelog_user") == person.id
  end

  test "failed github auth doesn't sign you in", %{conn: conn} do
    conn =
      conn
      |> assign(:ueberauth_failure, %{})
      |> get("/auth/github/callback")

    assert conn.status == 200
    assert get_encrypted_cookie(conn, "_changelog_user") == nil
  end

  test "successful github auth on new person sends you to join", %{conn: conn} do
    conn =
      conn
      |> assign(:ueberauth_auth, %{provider: :github, info: %{nickname: "joeblow"}})
      |> get("/auth/github/callback")

    assert redirected_to(conn) == person_path(conn, :new)
  end

  test "successful twitter auth on existing person signs you in", %{conn: conn} do
    person = insert(:person, twitter_handle: "joeblow")

    conn =
      conn
      |> assign(:ueberauth_auth, %{provider: :twitter, info: %{nickname: "joeblow"}})
      |> get("/auth/github/callback")

    assert redirected_to(conn) == page_path(conn, :home)
    assert get_encrypted_cookie(conn, "_changelog_user") == person.id
  end

  test "failed twitter auth doesn't sign you in", %{conn: conn} do
    conn =
      conn
      |> assign(:ueberauth_failure, %{})
      |> get("/auth/twitter/callback")

    assert conn.status == 200
    assert get_encrypted_cookie(conn, "_changelog_user") == nil
  end
end
