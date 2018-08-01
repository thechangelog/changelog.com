defmodule ChangelogWeb.Admin.PersonController do
  use ChangelogWeb, :controller

  alias Changelog.{Mailer, Newsletters, Person}
  alias ChangelogWeb.Email
  alias Craisin.Subscriber

  plug :assign_person when action in [:edit, :update, :delete]
  plug Authorize, [Policies.Person, :person]
  plug :scrub_params, "person" when action in [:create, :update]

  def index(conn, params) do
    page =
      Person
      |> order_by([p], desc: p.id)
      |> Repo.paginate(params)

    render(conn, :index, people: page.entries, page: page)
  end

  def new(conn, _params) do
    changeset = Person.admin_insert_changeset(%Person{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"person" => person_params}) do
    changeset = Person.admin_insert_changeset(%Person{}, person_params)

    case Repo.insert(changeset) do
      {:ok, person} ->
        Repo.update(Person.file_changeset(person, person_params))

        community = Newsletters.community()
        Subscriber.subscribe(community.list_id, person, handle: person.handle)
        handle_welcome_email(person, params)

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_person_path(conn, :edit, person))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn = %{assigns: %{person: person}}, _params) do
    changeset = Person.admin_update_changeset(person)
    render(conn, :edit, person: person, changeset: changeset)
  end

  def update(conn = %{assigns: %{person: person}}, params = %{"person" => person_params}) do
    changeset = Person.admin_update_changeset(person, person_params)

    case Repo.update(changeset) do
      {:ok, _person} ->
        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_person_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, person: person, changeset: changeset)
    end
  end

  def delete(conn = %{assigns: %{person: person}}, _params) do
    Repo.delete!(person)
    community = Newsletters.community()
    Subscriber.unsubscribe(community.list_id, person.email)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_person_path(conn, :index))
  end

  defp assign_person(conn = %{params: %{"id" => id}}, _) do
    person = Repo.get!(Person, id)
    assign(conn, :person, person)
  end

  defp handle_welcome_email(person, params) do
    case Map.get(params, "welcome") do
      "generic" -> handle_generic_welcome_email(person)
      "guest" -> handle_guest_welcome_email(person)
      _else -> false
    end
  end
  defp handle_generic_welcome_email(person) do
    person = Person.refresh_auth_token(person, 60 * 24)
    Email.community_welcome(person) |> Mailer.deliver_later
  end
  defp handle_guest_welcome_email(person) do
    person = Person.refresh_auth_token(person, 60 * 24)
    Email.guest_welcome(person) |> Mailer.deliver_later
  end
end
