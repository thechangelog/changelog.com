defmodule Changelog.PodcastHost do
  use Changelog.Web, :model

  schema "podcast_hosts" do
    field :position, :integer

    belongs_to :podcast, Changelog.Podcast
    belongs_to :person, Changelog.Person

    timestamps
  end

  @required_fields ~w(position)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
