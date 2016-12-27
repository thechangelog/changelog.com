defmodule Changelog.PersonController do
  use Changelog.Web, :controller

  alias Changelog.Person

  def new(conn, params) do
    person = %Person{
      name: Map.get(params, "name"),
      email: Map.get(params, "email"),
      handle: Map.get(params, "handle"),
      github_handle: Map.get(params, "github_handle"),
      twitter_handle: Map.get(params, "twitter_handle")}

    render(conn, "new.html", changeset: Person.changeset(person))
  end

  def create(conn, %{"person" => person_params}) do
    changeset = Person.changeset(%Person{}, person_params)

    case Repo.insert(changeset) do
      {:ok, _person} ->
        conn
        |> put_flash(:success, "Only one step left! Check your inbox for a confirmation email.")
        |> redirect(to: page_path(conn, :home))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong. 😭")
        |> render("new.html", changeset: changeset)
    end
  end
end
