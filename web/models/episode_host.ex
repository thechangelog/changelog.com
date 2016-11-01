defmodule Changelog.EpisodeHost do
  use Changelog.Web, :model

  schema "episode_hosts" do
    field :position, :integer
    field :delete, :boolean, virtual: true

    belongs_to :person, Changelog.Person
    belongs_to :episode, Changelog.Episode

    timestamps
  end

  @required_fields ~w(position)
  @optional_fields ~w(episode_id person_id delete)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def by_position do
    from p in __MODULE__, order_by: p.position
  end

  def build_and_preload({person, position}) do
    %__MODULE__{position: position, person_id: person.id} |> Repo.preload(:person)
  end
end
