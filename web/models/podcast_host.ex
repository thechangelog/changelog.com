defmodule Changelog.PodcastHost do
  use Changelog.Web, :model

  schema "podcast_hosts" do
    field :position, :integer

    belongs_to :podcast, Changelog.Podcast
    belongs_to :person, Changelog.Person

    timestamps()
  end

  @required_fields ~w(position)
  @optional_fields ~w(podcast_id person_id)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def by_position do
    from p in __MODULE__, order_by: p.position
  end
end
