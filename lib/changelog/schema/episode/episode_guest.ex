defmodule Changelog.EpisodeGuest do
  use Changelog.Schema

  alias Changelog.{Episode, Merch, Person, Podcast}

  schema "episode_guests" do
    field :position, :integer
    field :thanks, :boolean, default: true
    field :discount_code, :string, default: ""
    field :delete, :boolean, virtual: true

    belongs_to :episode, Episode
    belongs_to :person, Person

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(position episode_id person_id thanks discount_code delete)a)
    |> validate_required([:position])
    |> foreign_key_constraint(:episode_id)
    |> foreign_key_constraint(:person_id)
    |> mark_for_deletion()
  end

  def preload_all(episode_guest) do
    episode_guest
    |> preload_episode()
    |> preload_person()
  end

  def preload_episode(query = %Ecto.Query{}), do: Ecto.Query.preload(query, episode: :podcast)
  def preload_episode(episode_guest), do: Repo.preload(episode_guest, episode: :podcast)

  def preload_person(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :person)
  def preload_person(episode_guest), do: Repo.preload(episode_guest, :person)

  def no_thanks(episode_guest) do
    episode_guest
    |> changeset(%{thanks: false})
    |> Repo.update()
  end

  def thanks(episode_guest = %{discount_code: ""}) do
    episode_guest = preload_episode(episode_guest)
    podcast = episode_guest.episode.podcast

    code =
      case Merch.create_discount(thanks_code(episode_guest), discount(podcast)) do
        {:ok, dc} -> dc.code
        {:error, _} -> ""
      end

    episode_guest
    |> changeset(%{thanks: true, discount_code: code})
    |> Repo.update()
  end

  def thanks(episode_guest) do
    episode_guest
    |> changeset(%{thanks: true})
    |> Repo.update()
  end

  defp discount(podcast) do
    if Podcast.is_a_changelog_pod(podcast), do: "-30.0", else: "-10.0"
  end

  defp thanks_code(episode_guest) do
    episode_guest = Repo.preload(episode_guest, :person)
    handle = episode_guest.person.handle
    id = hashid(episode_guest)

    "thanks-#{handle}-#{id}"
  end
end
