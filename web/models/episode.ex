defmodule Changelog.Episode do
  use Changelog.Web, :model

  alias Changelog.Regexp

  schema "episodes" do
    field :title, :string
    field :slug, :string
    field :published, :boolean, default: false
    field :published_at, Timex.Ecto.DateTime
    field :recorded_at, Timex.Ecto.DateTime
    field :duration, :integer
    field :summary, :string

    belongs_to :podcast, Changelog.Podcast

    timestamps
  end

  @required_fields ~w(slug title published)
  @optional_fields ~w(published_at recorded_at duration summary)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:episodes_slug_podcast_id_index)
  end
end
