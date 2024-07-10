defmodule ChangelogWeb.PersonController do
  use ChangelogWeb, :controller

  alias Changelog.{
    Cache,
    Captcha,
    Episode,
    MapKit,
    Newsletters,
    Person,
    Podcast,
    Repo,
    Subscription
  }

  alias Changelog.ObanWorkers.MailDeliverer

  plug RequireGuest, "before joining" when action in [:join]

  def join(conn = %{method: "GET"}, params) do
    person = %Person{
      name: Map.get(params, "name"),
      email: Map.get(params, "email"),
      handle: Map.get(params, "handle"),
      github_handle: Map.get(params, "github_handle"),
      twitter_handle: Map.get(params, "twitter_handle"),
      mastodon_handle: Map.get(params, "mastodon_handle"),
      linkedin_handle: Map.get(params, "linkedin_handle")
    }

    render(conn, :join, changeset: Person.insert_changeset(person), person: nil)
  end

  # This is the join method does that actual processing
  def join(conn = %{method: "POST"}, params = %{"person" => person_params}) do
    captcha = Map.get(params, "cf-turnstile-response")
    email = Map.get(person_params, "email")

    if Captcha.verify(captcha) do
      if _person = Repo.get_by(Person, email: email) do
        # If the person's email already existed in the DB it isn't safe to update profile info until they have signed in.
        # Don't populate the form with the existing person's details when returning the error.
        changeset = Person.insert_changeset(%Person{}, person_params)

        conn
        |> put_flash(:error, "Member exists with that email address. Please sign in.")
        |> render(:join, changeset: changeset, person: nil)
      else
        changeset = Person.insert_changeset(%Person{public_profile: false}, person_params)

        case Repo.insert(changeset) do
          {:ok, person} ->
            Repo.update(Person.file_changeset(person, person_params))
            maybe_sign_up_for_news(person, params, "you signed up while joining")
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
    redirect(conn, to: ~p"/join")
  end

  def show(conn, params = %{"handle" => handle}) do
    person = Repo.get_by!(Person, handle: handle, public_profile: true)
    episode_ids = Person.participating_episode_ids(person)

    page =
      Episode
      |> Episode.with_ids(episode_ids)
      |> Episode.published()
      |> Episode.newest_first()
      |> Episode.exclude_transcript()
      |> Episode.preload_all()
      |> Repo.paginate(Map.put(params, :page_size, 20))

    conn
    |> assign(:person, person)
    |> assign(:page, page)
    |> render(:show)
  end

  def news(conn, %{"handle" => handle}) do
    conn
    |> put_status(301)
    |> redirect(to: ~p"/person/#{handle}")
  end

  def podcasts(conn, %{"handle" => handle}) do
    conn
    |> put_status(301)
    |> redirect(to: ~p"/person/#{handle}")
  end

  def subscribe(conn = %{method: "GET"}, %{"to" => "weekly"}) do
    redirect(conn, to: ~p"/subscribe/news")
  end

  def subscribe(conn = %{method: "GET"}, params = %{"to" => "nightly"}) do
    newsletter = Newsletters.nightly()

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
      redirect(conn, to: ~p"/subscribe")
    end
  end

  def subscribe(conn = %{method: "GET"}, _params) do
    render(conn, :subscribe)
  end

  # This is the subscribe method does that actual processing
  def subscribe(conn = %{method: "POST"}, params = %{"email" => email}) do
    subscribe_to = Map.get(params, "to", "news")
    captcha = Map.get(params, "cf-turnstile-response")

    if Captcha.verify(captcha) do
      if person = Repo.get_by(Person, email: email) do
        # account already exists, just send over the welcome email
        welcome_subscriber(conn, person, subscribe_to)
      else
        changeset =
          Person.with_fake_data()
          |> Person.insert_changeset(MapKit.sans_blanks(params))

        case Repo.insert(changeset) do
          {:ok, person} ->
            log_request(conn)

            maybe_sign_up_for_news(
              person,
              params,
              "you signed up while subscribing to #{subscribe_to}"
            )

            welcome_subscriber(conn, person, subscribe_to)

          {:error, _changeset} ->
            conn
            |> put_flash(:error, "Something went wrong. 😭")
            |> redirect(to: ~p"/subscribe/#{subscribe_to}")
        end
      end
    else
      conn
      |> put_flash(:error, "CAPTCHA fail. Are you blocking scripts? Are you a robot? 🤖")
      |> redirect(to: ~p"/subscribe/#{subscribe_to}")
    end
  end

  def subscribe(conn = %{method: "POST"}, _params) do
    redirect(conn, to: ~p"/subscribe")
  end

  defp maybe_sign_up_for_news(person, %{"news_subscribe" => _present}, context) do
    news = Podcast.get_by_slug!("news")
    Subscription.subscribe(person, news, context)
  end

  defp maybe_sign_up_for_news(_person, _params, _context), do: nil

  defp welcome_subscriber(conn, person, subscribe_to) do
    person = Person.refresh_auth_token(person)

    case Newsletters.get_by_slug(subscribe_to) do
      nil -> subscribe_to_podcast(person, subscribe_to)
      newsletter -> subscribe_to_newsletter(person, newsletter)
    end

    conn
    |> put_flash(:success, "Only one step left! Check your inbox for a confirmation email.")
    |> redirect(to: ~p"/")
  end

  defp subscribe_to_newsletter(person, newsletter) do
    Craisin.Subscriber.subscribe(newsletter.id, Person.sans_fake_data(person))

    MailDeliverer.queue("subscriber_welcome", %{
      "person" => person.id,
      "newsletter" => newsletter.slug
    })
  end

  defp subscribe_to_podcast(person, "master") do
    for podcast <- Cache.active_podcasts() do
      context = "you signed up for email notifications on changelog.com"
      Subscription.subscribe(person, podcast, context)
    end

    MailDeliverer.queue("subscriber_welcome", %{"person" => person.id, "podcast" => "master"})
  end

  defp subscribe_to_podcast(person, slug) do
    podcast = Podcast.get_by_slug!(slug)
    context = "you signed up for email notifications on changelog.com"

    Subscription.subscribe(person, podcast, context)
    MailDeliverer.queue("subscriber_welcome", %{"person" => person.id, "podcast" => podcast.slug})
  end

  defp welcome_community(conn, person) do
    person = Person.refresh_auth_token(person)

    MailDeliverer.queue("community_welcome", %{"person" => person.id})

    conn
    |> put_flash(:success, "Only one step left! Check your inbox for a confirmation email.")
    |> redirect(to: ~p"/")
  end
end
