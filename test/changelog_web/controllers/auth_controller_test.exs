defmodule ChangelogWeb.AuthControllerTest do
  use ChangelogWeb.ConnCase
  use Bamboo.Test

  alias Changelog.Person

  test "getting the sign in form", %{conn: conn} do
    conn = get(conn, sign_in_path(conn, :new))
    assert html_response(conn, 200) =~ "Sign In"
  end

  @tag :as_user
  test "getting the sign in form when signed in is not allowed", %{conn: conn} do
    conn = get(conn, sign_in_path(conn, :new))
    assert html_response(conn, 302)
    assert conn.halted
  end

  test "submitting the form with known email sets auth token and sends email", %{conn: conn} do
    person = insert(:person, auth_token: nil)

    conn = post(conn, "/in", auth: %{email: person.email})
    person = Repo.get(Person, person.id)

    assert html_response(conn, 200) =~ "Check your email"
    assert person.auth_token != nil
    assert_delivered_email ChangelogWeb.Email.sign_in(person)
  end

  test "submitting the form with unknown email sends you to join", %{conn: conn} do
    conn = post(conn, "/in", auth: %{email: "joe@blow.com"})

    assert redirected_to(conn) == person_path(conn, :join, %{email: "joe@blow.com"})
  end

  test "following a valid auth token signs you in", %{conn: conn} do
    person = insert(:person)

    changeset = Person.auth_changeset(person, %{
      auth_token: "12345",
      auth_token_expires_at: hours_from_now(0.25)
    })

    {:ok, person} = Repo.update(changeset)
    {:ok, encoded} = Person.encoded_auth(person)

    conn = get(conn, "/in/#{encoded}")

    assert redirected_to(conn) == home_path(conn, :show)
    assert get_encrypted_cookie(conn, "_changelog_user") == person.id
  end

  test "following an invalid auth token doesn't sign you in", %{conn: conn} do
    conn = get(conn, "/in/asdf1234")

    assert html_response(conn, 200) =~ "Sign In"
    assert is_nil(get_encrypted_cookie(conn, "_changelog_user"))
  end

  test "following an expired auth token doesn't sign you in", %{conn: conn} do
    person = insert(:person)

    changeset = Person.auth_changeset(person, %{
      auth_token: "12345",
      auth_token_expires_at: hours_ago(0.25)
    })

    {:ok, person} = Repo.update(changeset)
    {:ok, encoded} = Person.encoded_auth(person)

    conn = get(conn, "/in/#{encoded}")

    assert html_response(conn, 200) =~ "Sign In"
    refute get_encrypted_cookie(conn, "_changelog_user") == person.id
  end

  describe "github auth" do
    test "successful auth on existing person signs you in", %{conn: conn} do
      person = insert(:person, github_handle: "joeblow")

      conn =
        conn
        |> assign(:ueberauth_auth, %{provider: :github, info: %{nickname: "joeblow"}})
        |> get("/auth/github/callback")

      assert redirected_to(conn) == home_path(conn, :show)
      assert get_encrypted_cookie(conn, "_changelog_user") == person.id
    end

    test "successful auth on new person sends you to join", %{conn: conn} do
      conn =
        conn
        |> assign(:ueberauth_auth, %{provider: :github, info: %{name: "Joe Blow", nickname: "joeblow"}})
        |> get("/auth/github/callback")

      assert redirected_to(conn) == person_path(conn, :join, %{name: "Joe Blow", handle: "joeblow", github_handle: "joeblow"})
    end

    test "failed auth doesn't sign you in", %{conn: conn} do
      conn =
        conn
        |> assign(:ueberauth_failure, %{})
        |> get("/auth/github/callback")

      assert conn.status == 200
      assert get_encrypted_cookie(conn, "_changelog_user") == nil
    end
  end

  describe "twitter auth" do
    test "successful twitter auth on existing person signs you in", %{conn: conn} do
      person = insert(:person, twitter_handle: "joeblow")

      conn =
        conn
        |> assign(:ueberauth_auth, %{provider: :twitter, info: %{nickname: "joeblow"}})
        |> get("/auth/github/callback")

      assert redirected_to(conn) == home_path(conn, :show)
      assert get_encrypted_cookie(conn, "_changelog_user") == person.id
    end

    test "successful twitter auth on new person sends you to join", %{conn: conn} do
      conn =
        conn
        |> assign(:ueberauth_auth, %{provider: :twitter, info: %{name: "Joe Blow", nickname: "joeblow"}})
        |> get("/auth/github/callback")

      assert redirected_to(conn) == person_path(conn, :join, %{name: "Joe Blow", handle: "joeblow", twitter_handle: "joeblow"})
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

  describe "unsupported provider auth" do
    test "raises a typical 404", %{conn: conn} do
      assert_raise Ecto.NoResultsError, fn ->
        get(conn, "/auth/login")
      end
    end
  end
end
