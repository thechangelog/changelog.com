defmodule Changelog.Episode do
  use Changelog.Web, :model

  alias Changelog.Regexp

  schema "episodes" do
    field :title, :string
    field :slug, :string
    field :published, :boolean, default: false
    field :published_at, Ecto.DateTime
    field :recorded_at, Ecto.DateTime
    field :duration, :integer
    field :summary, :string

    belongs_to :podcast, Changelog.Podcast
    has_many :episode_hosts, Changelog.EpisodeHost, on_delete: :delete_all
    has_many :hosts, through: [:episode_hosts, :person]
    has_many :episode_guests, Changelog.EpisodeGuest, on_delete: :delete_all
    has_many :guests, through: [:episode_guests, :person]

    timestamps
  end

  @required_fields ~w(slug title published)
  @optional_fields ~w(published_at recorded_at duration summary)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:episodes_slug_podcast_id_index)
    |> cast_assoc(:episode_hosts, required: true)
  end
end
