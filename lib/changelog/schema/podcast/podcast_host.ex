defmodule Changelog.PodcastHost do
  use Changelog.Schema

  alias Changelog.{Person, Podcast}

  schema "podcast_hosts" do
    field :position, :integer
    field :retired, :boolean, default: false
    field :delete, :boolean, virtual: true

    belongs_to :person, Person
    belongs_to :podcast, Podcast

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(position retired podcast_id person_id delete)a)
    |> validate_required([:position])
    |> foreign_key_constraint(:person_id)
    |> foreign_key_constraint(:podcast_id)
    |> mark_for_deletion()
  end
end
