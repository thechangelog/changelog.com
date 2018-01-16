defmodule ChangelogWeb.PersonController do
  use ChangelogWeb, :controller

  alias Changelog.{Faker, Mailer, Newsletters, Person}
  alias ChangelogWeb.Email
  alias Craisin.Subscriber

  plug RequireGuest, "before joining" when action in [:subscribe, :join]

  def subscribe(conn = %{method: "GET"}, _params) do
    render(conn, :subscribe)
  end

  def subscribe(conn = %{method: "POST"}, params = %{"email" => email}) do
    if person = Repo.one(from q in Person, where: q.email == ^email) do
      welcome_subscriber(conn, person)
    else
      fake_name = Faker.name
      fake_handle = Faker.handle(fake_name)
      changeset = Person.changeset(%Person{name: fake_name, handle: fake_handle}, params)

      case Repo.insert(changeset) do
        {:ok, person} ->
          welcome_subscriber(conn, person)
        {:error, changeset} ->
          conn
          |> put_flash(:error, "Something went wrong. 😭")
          |> render(:subscribe)
      end
    end
  end

  defp welcome_subscriber(conn, person) do
    person = Person.refresh_auth_token(person)
    community = Newsletters.community()
    weekly = Newsletters.weekly()

    Email.subscriber_welcome(person) |> Mailer.deliver_later
    Subscriber.subscribe(community.list_id, person)
    Subscriber.subscribe(weekly.list_id, person)

    conn
    |> put_resp_cookie("hide_subscribe_cta", "true", http_only: false)
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

    render(conn, :join, changeset: Person.changeset(person), person: nil)
  end

  def join(conn = %{method: "POST"}, %{"person" => person_params = %{"email" => email}}) do
    if person = Repo.one(from p in Person, where: p.email == ^email) do
      welcome_community(conn, person)
    else
      changeset = Person.changeset(%Person{}, person_params)

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
    |> put_flash(:success, "Only one step left! Check your inbox for a confirmation email.")
    |> redirect(to: root_path(conn, :index))
  end
end
