defmodule ChangelogWeb.Admin.PersonController do
  use ChangelogWeb, :controller

  alias Changelog.{
    Episode,
    EpisodeRequest,
    Fastly,
    NewsItem,
    NewsItemComment,
    Newsletters,
    Person,
    Podcast,
    Slack,
    Zulip,
    Subscription
  }

  alias Changelog.ObanWorkers.MailDeliverer

  plug :assign_person
       when action in [:show, :edit, :update, :delete, :slack, :zulip, :news, :comments, :masq]

  plug Authorize, [Policies.Admin.Person, :person]
  plug :scrub_params, "person" when action in [:create, :update]

  def index(conn, params) do
    filter = Map.get(params, "filter", "all")
    params = Map.put(params, :page_size, 50)

    page =
      case filter do
        "admin" -> Person.admins()
        "host" -> Person.hosts()
        "editor" -> Person.editors()
        "spammy" -> Person.spammy()
        "uncomfirmed" -> Person.needs_confirmation()
        _else -> Person
      end
      |> Person.newest_first()
      |> Repo.paginate(params)

    conn
    |> assign(:people, page.entries)
    |> assign(:filter, filter)
    |> assign(:page, page)
    |> render(:index)
  end

  def show(conn = %{assigns: %{person: person}}, _params) do
    episodes =
      person
      |> assoc(:guest_episodes)
      |> Episode.published()
      |> Episode.newest_first()
      |> Episode.preload_all()
      |> Repo.all()

    episode_requests =
      person
      |> assoc(:episode_requests)
      |> EpisodeRequest.preload_all()
      |> Repo.all()

    subscriptions =
      person
      |> assoc(:subscriptions)
      |> Subscription.subscribed()
      |> Subscription.to_podcast()
      |> Subscription.preload_podcast()
      |> Repo.all()

    published =
      NewsItem
      |> NewsItem.with_person(person)
      |> NewsItem.published()
      |> NewsItem.newest_first()
      |> NewsItem.limit(5)
      |> NewsItem.preload_all()
      |> Repo.all()

    declined =
      NewsItem
      |> NewsItem.with_person(person)
      |> NewsItem.declined()
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.all()

    comments =
      person
      |> assoc(:comments)
      |> NewsItemComment.newest_first()
      |> NewsItemComment.limit(5)
      |> NewsItemComment.preload_all()
      |> Repo.all()

    podcasts =
      Podcast.active()
      |> Podcast.by_position()
      |> Repo.all()

    feeds =
      person
      |> assoc(:feeds)
      |> Repo.all()

    conn
    |> assign(:person, person)
    |> assign(:episodes, episodes)
    |> assign(:episode_requests, episode_requests)
    |> assign(:subscriptions, subscriptions)
    |> assign(:published, published)
    |> assign(:declined, declined)
    |> assign(:comments, comments)
    |> assign(:podcasts, podcasts)
    |> assign(:feeds, feeds)
    |> render(:show)
  end

  def new(conn, _params) do
    changeset = Person.admin_insert_changeset(%Person{approved: true})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"person" => person_params}) do
    person_params = authorized_params(conn.assigns.current_user, nil, person_params)
    changeset = Person.admin_insert_changeset(%Person{}, person_params)

    case Repo.insert(changeset) do
      {:ok, person} ->
        Repo.update(Person.file_changeset(person, person_params))

        handle_welcome_email(person, params)

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, ~p"/admin/people/#{person}/edit")

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
    person_params = authorized_params(conn.assigns.current_user, person, person_params)
    changeset = Person.admin_update_changeset(person, person_params)

    case Repo.update(changeset) do
      {:ok, person} ->
        Fastly.purge(person)

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, ~p"/admin/people")

      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, person: person, changeset: changeset)
    end
  end

  def delete(conn = %{assigns: %{person: person}}, params) do
    Repo.delete!(person)

    Craisin.Subscriber.delete(Newsletters.nightly().id, person.email)

    send_to_sentry("person_delete", %{
      person: person.id,
      referer: Plug.Conn.get_req_header(conn, "referer")
    })

    conn
    |> put_flash(:result, "success")
    |> redirect_next(params, ~p"/admin/people")
  end

  def comments(conn = %{assigns: %{person: person}}, params) do
    page =
      person
      |> assoc(:comments)
      |> NewsItemComment.newest_first()
      |> NewsItemComment.preload_all()
      |> Repo.paginate(params)

    conn
    |> assign(:comments, page.entries)
    |> assign(:page, page)
    |> render(:comments)
  end

  def news(conn = %{assigns: %{person: person}}, params) do
    page =
      NewsItem
      |> NewsItem.with_person(person)
      |> NewsItem.published()
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.paginate(params)

    conn
    |> assign(:published, page.entries)
    |> assign(:page, page)
    |> render(:news)
  end

  def slack(conn = %{assigns: %{person: person}}, params) do
    flash =
      case Slack.Client.invite(person.email) do
        %{"ok" => true} ->
          "success"

        %{"ok" => false, "error" => "already_in_team"} ->
          "success"

        _else ->
          "failure"
      end

    conn
    |> put_flash(:result, flash)
    |> redirect_next(params, ~p"/admin/people")
  end

  def zulip(conn = %{assigns: %{person: person}}, params) do
    flash =
      case Zulip.invite(person.email) do
        %{"ok" => true} ->
          "success"
        _else ->
          "failure"
      end

    conn
    |> put_flash(:result, flash)
    |> redirect_next(params, ~p"/admin/people")
  end

  def masq(conn = %{assigns: %{person: person}}, _params) do
    conn
    |> put_session("id", person.id)
    |> configure_session(renew: true)
    |> put_flash(:success, "Now using the site as #{person.name}")
    |> redirect(to: ~p"/")
  end

  defp assign_person(conn = %{params: %{"id" => id}}, _) do
    person = Person |> Repo.get!(id) |>Repo.preload(:active_membership)
    assign(conn, :person, person)
  end

  defp authorized_params(actor, resource, params) do
    # if a person is created via the admin, it is assumed they are approved
    # for commenting unless specified otherwise by their creator
    params = Map.put_new(params, "approved", true)

    if Policies.Admin.Person.roles(actor, resource) do
      params
    else
      params
      |> Map.delete("admin")
      |> Map.delete("host")
      |> Map.delete("editor")
    end
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
    MailDeliverer.queue("community_welcome", %{"person" => person.id})
  end

  defp handle_guest_welcome_email(person) do
    person = Person.refresh_auth_token(person)
    MailDeliverer.queue("guest_welcome", %{"person" => person.id})
  end
end
