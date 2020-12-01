defmodule Changelog.EpisodeGuest do
  use Changelog.Schema

  alias Changelog.{Episode, Merch, Person}

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

  def no_thanks(episode_guest) do
    episode_guest
    |> changeset(%{thanks: false})
    |> Repo.update()
  end

  def thanks(episode_guest = %{discount_code: ""}) do
    code =
      case Merch.create_discount(thanks_code(episode_guest), "-28.0") do
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

  defp thanks_code(episode_guest) do
    episode_guest = Repo.preload(episode_guest, :person)
    handle = episode_guest.person.handle
    id = hashid(episode_guest)

    "thanks-#{handle}-#{id}"
  end
end
