defmodule Changelog.EpisodeGuest do
  use Changelog.Schema

  alias Changelog.{Episode, Person}

  schema "episode_guests" do
    field :position, :integer
    field :thanks, :boolean, default: true
    field :delete, :boolean, virtual: true

    belongs_to :episode, Episode
    belongs_to :person, Person

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(position episode_id person_id thanks delete)a)
    |> validate_required([:position])
    |> foreign_key_constraint(:episode_id)
    |> foreign_key_constraint(:person_id)
    |> mark_for_deletion()
  end
end
