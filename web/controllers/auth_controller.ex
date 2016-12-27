defmodule Changelog.AuthController do
  use Changelog.Web, :controller

  alias Changelog.{Person, Email, Mailer}

  plug Ueberauth

  def new(conn, %{"auth" =>  %{"email" => email}}) do
    person = Repo.one!(from p in Person, where: p.email == ^email)

    auth_token = Base.encode16(:crypto.strong_rand_bytes(8))
    expires_at = Timex.now |> Timex.add(Timex.Duration.from_minutes(15))

    changeset = Person.auth_changeset(person, %{
      auth_token: auth_token,
      auth_token_expires_at: expires_at
    })

    case Repo.update(changeset) do
      {:ok, person} ->
        Email.sign_in_email(person) |> Mailer.deliver_later
        render conn, "new.html", person: person
      {:error, _} ->
        conn
        |> put_flash(:info, "try again!")
        |> render("new.html", person: nil)
    end
  end

  def new(conn, _params) do
    render(conn, "new.html", person: nil)
  end

  def create(conn, %{"token" => token}) do
    [email, auth_token] = Person.decoded_auth(token)
    person = Repo.get_by(Person, email: email, auth_token: auth_token)

    if person && Timex.before?(Timex.now, person.auth_token_expires_at) do
      sign_in_and_redirect(conn, person, page_path(conn, :home))
    else
      conn
      |> put_flash(:info, "Whoops!")
      |> render("new.html", person: nil)
    end
  end

  def delete(conn, _params) do
    conn
      |> configure_session(drop: true)
      |> delete_resp_cookie("_changelog_user")
      |> redirect(to: page_path(conn, :home))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    person = Person.get_by_ueberauth(auth)

    if person do
      sign_in_and_redirect(conn, person, page_path(conn, :home))
    else
      conn
      |> put_flash(:success, "Almost there! Please complete your profile now.")
      |> redirect(to: person_path(conn, :new, params_from_ueberauth(auth)))
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Something went wrong. 😭")
    |> render("new.html", person: nil)
  end

  defp params_from_ueberauth(%{provider: :github, info: info}) do
    %{name: info.name, handle: info.nickname, github_handle: info.nickname}
  end

  defp params_from_ueberauth(%{provider: :twitter, info: info}) do
    %{name: info.name, handle: info.nickname, twitter_handle: info.nickname}
  end

  defp sign_in_and_redirect(conn, person, route) do
    Repo.update(Person.sign_in_changes(person))

    conn
    |> assign(:current_user, person)
    |> put_encrypted_cookie("_changelog_user", person.id)
    |> configure_session(renew: true)
    |> redirect(to: route)
  end
end
