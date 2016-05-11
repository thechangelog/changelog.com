defmodule Changelog.EpisodeLink do
  use Changelog.Web, :model

  alias Changelog.Regexp

  schema "episode_links" do
    field :title, :string
    field :url, :string
    field :position, :integer

    belongs_to :episode, Changelog.Episode

    timestamps
  end

  @required_fields ~w(url position)
  @optional_fields ~w(title episode_id)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:url, Regexp.http, message: Regexp.http_message)
  end

  def by_position do
    from p in __MODULE__, order_by: p.position
  end
end
