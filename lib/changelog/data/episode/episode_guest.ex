defmodule Changelog.EpisodeGuest do
  use Changelog.Data

  alias Changelog.{Episode, Person}

  schema "episode_guests" do
    field :position, :integer
    field :thanks, :boolean, default: true
    field :delete, :boolean, virtual: true

    belongs_to :person, Person
    belongs_to :episode, Episode

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(position episode_id person_id thanks delete)a)
    |> validate_required([:position])
    |> mark_for_deletion()
  end
end
