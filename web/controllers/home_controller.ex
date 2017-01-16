defmodule Changelog.HomeController do
  use Changelog.Web, :controller

  alias Changelog.{Person, Slack}

  plug RequireUser

  def show(conn, _params) do
    render(conn, :show)
  end

  def edit(%{assigns: %{current_user: current_user}} = conn, _params) do
    render(conn, :edit, changeset: Person.changeset(current_user))
  end

  def update(%{assigns: %{current_user: current_user}} = conn, %{"person" => person_params}) do
    changeset = Person.changeset(current_user, person_params)

    case Repo.update(changeset) do
      {:ok, _person} ->
        conn
        |> put_flash(:success, "Profile updated!")
        |> redirect(to: home_path(conn, :show))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "The was a problem!")
        |> render(:edit, person: current_user, changeset: changeset)
    end
  end

  def slack(%{assigns: %{current_user: current_user}} = conn, _params) do
    flash = case Slack.Client.invite(current_user.email) do
      %{ok: true} -> "Invite sent! 🎯"
      %{ok: false, error: "already_in_team"} -> "You're on the team! We'll see you in there ✊"
      %{ok: false, error: error} -> "Hmm, Slack is saying '#{error}' 🤔"
    end

    conn
    |> put_flash(:success, flash)
    |> render(:show)
  end
end
