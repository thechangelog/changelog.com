defmodule ChangelogWeb.PersonController do
  use ChangelogWeb, :controller

  alias Changelog.{
    Cache,
    Captcha,
    Episode,
    Mailer,
    NewsItem,
    Newsletters,
    Person,
    Podcast,
    Repo,
    Subscription
  }

  alias ChangelogWeb.Email

  plug RequireGuest, "before joining" when action in [:join]

  def join(conn = %{method: "GET"}, params) do
    person = %Person{
      name: Map.get(params, "name"),
      email: Map.get(params, "email"),
      handle: Map.get(params, "handle"),
      github_handle: Map.get(params, "github_handle"),
      twitter_handle: Map.get(params, "twitter_handle")
    }

    render(conn, :join, changeset: Person.insert_changeset(person), person: nil)
  end

  # This is the join method does that actual processing
  def join(conn = %{method: "POST"}, params = %{"person" => person_params}) do
    captcha = Map.get(params, "cf-turnstile-response")
    email = Map.get(person_params, "email")

    if Captcha.verify(captcha) do
      if person = Repo.get_by(Person, email: email) do
        welcome_community(conn, person)
      else
        changeset = Person.insert_changeset(%Person{public_profile: false}, person_params)

        case Repo.insert(changeset) do
          {:ok, person} ->
            Repo.update(Person.file_changeset(person, person_params))
            welcome_community(conn, person)

          {:error, changeset} ->
            conn
            |> put_flash(:error, "Something went wrong. 😭")
            |> render(:join, changeset: changeset, person: nil)
        end
      end
    else
      changeset = Person.insert_changeset(%Person{}, person_params)

      conn
      |> put_flash(:error, "CAPTCHA fail. Are you blocking scripts? Are you a robot? 🤖")
      |> render(:join, changeset: changeset, person: nil)
    end
  end

  def join(conn = %{method: "POST"}, _params) do
    redirect(conn, to: Routes.person_path(conn, :join))
  end

  def show(conn, params = %{"handle" => handle}) do
    person = Repo.get_by!(Person, handle: handle, public_profile: true)

    episodes =
      person
      |> Person.participating_episode_ids()
      |> Episode.with_ids()
      |> Episode.published()
      |> Episode.exclude_transcript()
      |> Repo.all()

    page =
      person
      |> NewsItem.with_person_or_episodes(episodes)
      |> NewsItem.published()
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.paginate(Map.put(params, :page_size, 20))

    items =
      page.entries
      |> Enum.map(&NewsItem.load_object/1)

    conn
    |> assign(:person, person)
    |> assign(:items, items)
    |> assign(:page, page)
    |> render(:show)
  end

  def news(conn, params = %{"handle" => handle}) do
    person = Repo.get_by!(Person, handle: handle)

    page =
      NewsItem
      |> NewsItem.with_person(person)
      |> NewsItem.published()
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.paginate(Map.put(params, :page_size, 20))

    items =
      page.entries
      |> Enum.map(&NewsItem.load_object/1)

    conn
    |> assign(:person, person)
    |> assign(:items, items)
    |> assign(:page, page)
    |> assign(:tab, "news")
    |> render(:show)
  end

  def podcasts(conn, params = %{"handle" => handle}) do
    person = Repo.get_by!(Person, handle: handle)
    episode_ids = Person.participating_episode_ids(person)

    page =
      Episode
      |> Episode.with_ids(episode_ids)
      |> Episode.published()
      |> Episode.newest_first()
      |> Episode.exclude_transcript()
      |> Repo.paginate(Map.put(params, :page_size, 20))

    items =
      page.entries
      |> NewsItem.with_episodes()
      |> NewsItem.published()
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.all()
      |> Enum.map(&NewsItem.load_object/1)

    conn
    |> assign(:person, person)
    |> assign(:items, items)
    |> assign(:page, page)
    |> assign(:tab, "podcasts")
    |> render(:show)
  end

  def subscribe(conn = %{method: "GET"}, params = %{"to" => to}) when to in ["weekly", "nightly"] do
    newsletter = Newsletters.get_by_slug(to)

    conn
    |> assign(:newsletter, newsletter)
    |> assign(:email, params["email"])
    |> render(:subscribe_newsletter)
  end

  def subscribe(conn = %{method: "GET"}, params = %{"to" => to}) when is_binary(to) do
    podcast = Podcast.get_by_slug!(to)

    if Podcast.has_feed(podcast) do
      conn
      |> assign(:podcast, podcast)
      |> assign(:email, params["email"])
      |> render(:subscribe_podcast)
    else
      redirect(conn, to: Routes.person_path(conn, :subscribe))
    end
  end

  def subscribe(conn = %{method: "GET"}, _params) do
    render(conn, :subscribe)
  end

  # This is the subscribe method does that actual processing
  def subscribe(conn = %{method: "POST"}, params = %{"email" => email}) do
    subscribe_to = Map.get(params, "to", "weekly")
    captcha = Map.get(params, "cf-turnstile-response")

    if Captcha.verify(captcha) do
      if person = Repo.get_by(Person, email: email) do
        # account already exists, just send over the welcome email
        welcome_subscriber(conn, person, subscribe_to)
      else
        changeset =
          Person.with_fake_data()
          |> Person.insert_changeset(params)

        case Repo.insert(changeset) do
          {:ok, person} ->
            log_request(conn)
            welcome_subscriber(conn, person, subscribe_to)

          {:error, _changeset} ->
            conn
            |> put_flash(:error, "Something went wrong. 😭")
            |> redirect(to: Routes.person_path(conn, :subscribe, subscribe_to))
        end
      end
    else
      conn
      |> put_flash(:error, "CAPTCHA fail. Are you blocking scripts? Are you a robot? 🤖")
      |> redirect(to: Routes.person_path(conn, :subscribe, subscribe_to))
    end
  end

  def subscribe(conn = %{method: "POST"}, _params) do
    redirect(conn, to: Routes.person_path(conn, :subscribe))
  end

  defp welcome_subscriber(conn, person, subscribe_to) do
    person = Person.refresh_auth_token(person)

    case Newsletters.get_by_slug(subscribe_to) do
      nil -> subscribe_to_podcast(person, subscribe_to)
      newsletter -> subscribe_to_newsletter(person, newsletter)
    end

    conn
    |> put_flash(:success, "Only one step left! Check your inbox for a confirmation email.")
    |> redirect(to: Routes.root_path(conn, :index))
  end

  defp subscribe_to_newsletter(person, newsletter) do
    Craisin.Subscriber.subscribe(newsletter.list_id, Person.sans_fake_data(person))
    person |> Email.subscriber_welcome(newsletter) |> Mailer.deliver_later()
  end

  defp subscribe_to_podcast(person, "master") do
    for podcast <- Cache.podcasts() do
      context = "you signed up for email notifications on changelog.com"
      Subscription.subscribe(person, podcast, context)
    end

    person |> Email.subscriber_welcome(Podcast.master()) |> Mailer.deliver_later()
  end

  defp subscribe_to_podcast(person, slug) do
    podcast = Podcast.get_by_slug!(slug)
    context = "you signed up for email notifications on changelog.com"
    Subscription.subscribe(person, podcast, context)
    person |> Email.subscriber_welcome(podcast) |> Mailer.deliver_later()
  end

  defp welcome_community(conn, person) do
    person = Person.refresh_auth_token(person)

    Email.community_welcome(person) |> Mailer.deliver_later()

    conn
    |> put_flash(:success, "Only one step left! Check your inbox for a confirmation email.")
    |> redirect(to: Routes.root_path(conn, :index))
  end
end
