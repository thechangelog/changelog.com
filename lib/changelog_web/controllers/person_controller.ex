defmodule ChangelogWeb.PersonController do
  use ChangelogWeb, :controller

  alias Changelog.{Mailer, Newsletters, Person, Podcast, Repo}
  alias ChangelogWeb.Email
  alias Craisin.Subscriber

  plug RequireGuest, "before joining" when action in [:join]

  def subscribe(conn = %{method: "GET"}, _params) do
    active =
      Podcast.active
      |> Podcast.oldest_first
      |> Podcast.preload_hosts
      |> Repo.all
      |> Kernel.++([Podcast.master])

    render(conn, :subscribe, podcasts: active)
  end

  def subscribe(conn = %{method: "POST"}, params = %{"email" => email}) do
    list = Map.get(params, "list", "weekly")

    if person = Repo.get_by(Person, email: email) do
      welcome_subscriber(conn, person, list)
    else
      changeset =
        Person.with_fake_data()
        |> Person.insert_changeset(params)

      case Repo.insert(changeset) do
        {:ok, person} ->
          welcome_subscriber(conn, person, list)
        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Something went wrong. 😭")
          |> redirect(to: person_path(conn, :subscribe))
      end
    end
  end

  defp welcome_subscriber(conn, person, list) do
    person = Person.refresh_auth_token(person)
    newsletter = Newsletters.get_by_slug(list)
    community = Newsletters.community()

    Subscriber.subscribe(newsletter.list_id, Person.sans_fake_data(person))
    Subscriber.subscribe(community.list_id, Person.sans_fake_data(person))

    Email.subscriber_welcome(person, newsletter) |> Mailer.deliver_later

    conn
    |> put_resp_cookie("hide_subscribe_cta", "true", http_only: false)
    |> put_resp_cookie("hide_subscribe_banner", "true", http_only: false)
    |> put_flash(:success, "Only one step left! Check your inbox for a confirmation email.")
    |> redirect(to: root_path(conn, :index))
  end

  def join(conn = %{method: "GET"}, params) do
    person = %Person{
      name: Map.get(params, "name"),
      email: Map.get(params, "email"),
      handle: Map.get(params, "handle"),
      github_handle: Map.get(params, "github_handle"),
      twitter_handle: Map.get(params, "twitter_handle")}

    render(conn, :join, changeset: Person.insert_changeset(person), person: nil)
  end

  def join(conn = %{method: "POST"}, %{"person" => person_params = %{"email" => email}}) do
    if person = Repo.get_by(Person, email: email) do
      welcome_community(conn, person)
    else
      changeset = Person.insert_changeset(%Person{}, person_params)

      case Repo.insert(changeset) do
        {:ok, person} ->
          welcome_community(conn, person)
        {:error, changeset} ->
          conn
          |> put_flash(:error, "Something went wrong. 😭")
          |> render(:join, changeset: changeset, person: nil)
      end
    end
  end

  defp welcome_community(conn, person) do
    person = Person.refresh_auth_token(person)
    community = Newsletters.community()

    Email.community_welcome(person) |> Mailer.deliver_later
    Subscriber.subscribe(community.list_id, person, handle: person.handle)

    conn
    |> put_resp_cookie("hide_subscribe_cta", "true", http_only: false)
    |> put_resp_cookie("hide_subscribe_banner", "true", http_only: false)
    |> put_flash(:success, "Only one step left! Check your inbox for a confirmation email.")
    |> redirect(to: root_path(conn, :index))
  end
end
