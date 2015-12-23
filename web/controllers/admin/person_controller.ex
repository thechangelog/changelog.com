defmodule Changelog.Admin.PersonController do
  use Changelog.Web, :controller

  alias Changelog.Person

  plug :scrub_params, "person" when action in [:create, :update]

  def index(conn, _params) do
    people = Repo.all(Person)
    render conn, "index.html", people: people
  end

  def new(conn, _params) do
    changeset = Person.changeset(%Person{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"person" => person_params}) do
    changeset = Person.changeset(%Person{}, person_params)

    case Repo.insert(changeset) do
      {:ok, person} ->
        conn
        |> put_flash(:info, "#{person.name} created!")
        |> redirect(to: admin_person_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    person = Repo.get!(Person, id)
    changeset = Person.changeset(person)
    render(conn, "edit.html", person: person, changeset: changeset)
  end

  def update(conn, %{"id" => id, "person" => person_params}) do
    person = Repo.get!(Person, id)
    changeset = Person.changeset(person, person_params)

    case Repo.update(changeset) do
      {:ok, person} ->
        conn
        |> put_flash(:info, "#{person.name} udated!")
        |> redirect(to: admin_person_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", person: person, changeset: changeset)
    end
  end
end
