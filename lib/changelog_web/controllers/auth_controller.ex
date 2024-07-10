defmodule ChangelogWeb.AuthController do
  use ChangelogWeb, :controller

  alias Changelog.Person
  alias Changelog.ObanWorkers.MailDeliverer

  plug RequireGuest, "before signing in" when action in [:new, :create]
  plug Ueberauth

  def new(conn, %{"auth" => %{"email" => email}}) do
    if person = Repo.get_by(Person, email: email) do
      person = Person.refresh_auth_token(person)
      MailDeliverer.queue("sign_in", %{"person" => person.id})
      render(conn, "new.html", person: person)
    else
      conn
      |> put_flash(:success, "You aren't in our system! No worries, it's free to join. 💚")
      |> redirect(to: ~p"/join?#{%{email: email}}")
    end
  end

  def new(conn, _params) do
    render(conn, "new.html", person: nil)
  end

  def create(conn = %{method: "GET"}, %{"token" => token}) do
    conn
    |> assign(:token, token)
    |> render(:create)
  end

  def create(conn = %{method: "POST"}, %{"token" => token}) do
    person = Person.get_by_encoded_auth(token)

    if person && Timex.before?(Timex.now(), person.auth_token_expires_at) do
      sign_in_and_redirect(conn, person, ~p"/~")
    else
      conn
      |> put_flash(:error, "Whoops!")
      |> render("new.html", person: nil)
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: ~p"/")
  end

  def callback(conn = %{assigns: %{ueberauth_auth: auth}}, _params) do
    if person = Person.get_by_ueberauth(auth) do
      sign_in_and_redirect(conn, person, ~p"/~")
    else
      conn
      |> put_flash(:success, "Almost there! Please complete your profile now.")
      |> redirect(to: ~p"/join?#{params_from_ueberauth(auth)}")
    end
  end

  def callback(conn = %{assigns: %{ueberauth_failure: _fails}}, _params) do
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
    person |> Person.sign_in_changes() |> Repo.update()

    conn
    |> assign(:current_user, person)
    |> put_flash(:success, "Welcome to Changelog!")
    |> put_session("id", person.id)
    |> configure_session(renew: true)
    |> redirect(to: route)
  end
end
