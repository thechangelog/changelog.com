defmodule ChangelogWeb.Admin.PersonController do
  use ChangelogWeb, :controller

  alias Changelog.{Mailer, Episode, NewsItem, Person, Slack}
  alias ChangelogWeb.Email

  plug :assign_person when action in [:edit, :update, :delete, :slack]
  plug Authorize, [Policies.Person, :person]
  plug :scrub_params, "person" when action in [:create, :update]

  def index(conn, params) do
    filter = Map.get(params, "filter", "all")

    page =
      case filter do
        "admin"  -> Person.admins()
        "host"   -> Person.hosts()
        "editor" -> Person.editors()
        _else    -> Person
      end
      |> Person.newest_first()
      |> Repo.paginate(params)

    conn
    |> assign(:people, page.entries)
    |> assign(:filter, filter)
    |> assign(:page, page)
    |> render(:index)
  end

  def show(conn, %{"id" => id}) do
    person = Repo.get!(Person, id)

    episodes =
      assoc(person, :guest_episodes)
      |> Episode.published()
      |> Episode.newest_first()
      |> Episode.preload_all()
      |> Repo.all()

    published =
      NewsItem
      |> NewsItem.with_person(person)
      |> NewsItem.published()
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.all()

    declined =
      NewsItem
      |> NewsItem.with_person(person)
      |> NewsItem.declined()
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.all()

    conn
    |> assign(:person, person)
    |> assign(:episodes, episodes)
    |> assign(:published, published)
    |> assign(:declined, declined)
    |> render(:show)
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

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_person_path(conn, :index))
  end

  def slack(conn = %{assigns: %{person: person}}, params) do
    flash = case Slack.Client.invite(person.email) do
      %{"ok" => true} ->
        set_slack_id_to_pending(person)
        "success"
      %{"ok" => false, "error" => "already_in_team"} ->
        set_slack_id_to_pending(person)
        "success"
      _else -> "failure"
    end

    conn
    |> put_flash(:result, flash)
    |> redirect_next(params, admin_person_path(conn, :index))
  end

  defp assign_person(conn = %{params: %{"id" => id}}, _) do
    person = Repo.get!(Person, id)
    assign(conn, :person, person)
  end

  defp set_slack_id_to_pending(person = %{slack_id: id}) when not is_nil(id), do: person
  defp set_slack_id_to_pending(person) do
    {:ok, person} = Repo.update(Person.slack_changes(person, "pending"))
    person
  end

  defp handle_welcome_email(person, params) do
    case Map.get(params, "welcome") do
      "generic" -> handle_generic_welcome_email(person)
      "guest" -> handle_guest_welcome_email(person)
      _else -> false
    end
  end
  defp handle_generic_welcome_email(person) do
    person = Person.refresh_auth_token(person)
    Email.community_welcome(person) |> Mailer.deliver_later
  end
  defp handle_guest_welcome_email(person) do
    person = Person.refresh_auth_token(person)
    Email.guest_welcome(person) |> Mailer.deliver_later
  end
end
