defmodule ChangelogWeb.Admin.PodcastSubscriptionController do
  use ChangelogWeb, :controller

  alias Changelog.{CsvMapParser, Faker, Person, Podcast, Subscription}

  plug :assign_podcast
  plug Authorize, [Policies.Admin.Subscription, :podcast]

  def index(conn = %{assigns: %{podcast: podcast}}, params) do
    page =
      Subscription.on_podcast(podcast)
      |> Subscription.newest_first()
      |> Subscription.preload_person()
      |> Repo.paginate(params)

    conn
    |> assign(:subscriptions, page.entries)
    |> assign(:page, page)
    |> render(:index)
  end

  def import(conn = %{assigns: %{podcast: podcast}}, params) do
    context = params["context"]

    subs = CsvMapParser.parse_file(params["data"])

    {_success_count, _error_count} =
      Enum.reduce(subs, {0, 0}, fn row, {success, errors} ->
        case process_sub(row, podcast, context) do
          :ok -> {success + 1, errors}
          :error -> {success, errors + 1}
        end
      end)

    conn
    |> put_flash(:result, "success")
    |> redirect_next(params, ~p"/admin/podcasts/#{podcast.slug}/subscriptions")
  end

  defp process_sub(data, podcast, context) do
    email = data["email"]
    name = data["name"] || Faker.name()

    subbed_at =
      case Timex.parse(data["join_date"], "{ISO:Extended}") do
        {:ok, datetime} -> datetime
        {:error, _} -> Timex.now()
      end
      |> DateTime.to_naive()
      |> NaiveDateTime.truncate(:second)

    with {:ok, person} <- get_or_create_person(email, name, subbed_at),
         {:ok, _subscription} <- get_or_create_subscription(person, podcast, subbed_at, context) do
      :ok
    else
      _ -> :error
    end
  end

  defp get_or_create_person(nil, _name, _subbed_at), do: {:error, :missing_email}
  defp get_or_create_person("", _name, _subbed_at), do: {:error, :missing_email}

  defp get_or_create_person(email, name, subbed_at) do
    case Repo.get_by(Person, email: email) do
      %Person{} = person ->
        {:ok, person}

      nil ->
        %Person{}
        |> Person.insert_changeset(%{
          name: name,
          email: email,
          handle: Faker.handle(name),
          public_profile: false
        })
        |> Ecto.Changeset.put_change(:inserted_at, subbed_at)
        |> Ecto.Changeset.put_change(:updated_at, subbed_at)
        |> Repo.insert()
    end
  end

  defp get_or_create_subscription(person, podcast, subbed_at, context) do
    case Repo.get_by(Subscription, person_id: person.id, podcast_id: podcast.id) do
      %Subscription{} = subscription ->
        {:ok, subscription}

      nil ->
        %Subscription{}
        |> Ecto.Changeset.change(%{
          person_id: person.id,
          podcast_id: podcast.id,
          context: context,
          inserted_at: subbed_at,
          updated_at: subbed_at
        })
        |> Repo.insert()
    end
  end

  defp assign_podcast(conn = %{params: %{"podcast_id" => slug}}, _) do
    podcast = Podcast |> Repo.get_by!(slug: slug) |> Podcast.preload_active_hosts()
    assign(conn, :podcast, podcast)
  end
end
