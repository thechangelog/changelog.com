defmodule Changelog.PodcastHost do
  use Changelog.Data

  alias Changelog.{Person, Podcast}

  schema "podcast_hosts" do
    field :position, :integer
    field :delete, :boolean, virtual: true

    belongs_to :podcast, Podcast
    belongs_to :person, Person

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(position podcast_id person_id delete)a)
    |> validate_required([:position])
    |> mark_for_deletion()
  end
end
