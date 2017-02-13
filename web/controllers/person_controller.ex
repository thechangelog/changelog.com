defmodule Changelog.PersonController do
  use Changelog.Web, :controller

  alias Changelog.{Email, Mailer, Newsletter, Person}
  alias Craisin.Subscriber

  plug RequireGuest, "before joining" when action in [:new, :create]

  def new(conn, params) do
    person = %Person{
      name: Map.get(params, "name"),
      email: Map.get(params, "email"),
      handle: Map.get(params, "handle"),
      github_handle: Map.get(params, "github_handle"),
      twitter_handle: Map.get(params, "twitter_handle")}

    render(conn, :new, changeset: Person.changeset(person), person: nil)
  end

  def create(conn, %{"person" => person_params = %{"email" => email}}) do
    if person = Repo.one(from p in Person, where: p.email == ^email) do
      welcome(conn, person)
    else
      changeset = Person.changeset(%Person{}, person_params)

      case Repo.insert(changeset) do
        {:ok, person} ->
          welcome(conn, person)
        {:error, changeset} ->
          conn
          |> put_flash(:error, "Something went wrong. 😭")
          |> render(:new, changeset: changeset, person: nil)
      end
    end
  end

  defp welcome(conn, person) do
    person = Person.refresh_auth_token(person)
    community = Newsletter.community()

    Email.welcome_email(person) |> Mailer.deliver_later
    Subscriber.subscribe(community.list_id, person.email, person.name)

    conn
    |> put_flash(:success, "Only one step left! Check your inbox for a confirmation email.")
    |> render(:new, person: person)
  end
end
