defmodule Changelog.HomeController do
  use Changelog.Web, :controller

  alias Changelog.Person

  plug RequireUser

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def edit(%{assigns: %{current_user: current_user}} = conn, _params) do
    render(conn, "edit.html", changeset: Person.changeset(current_user))
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
        |> render("edit.html", person: current_user, changeset: changeset)
    end
  end
end
