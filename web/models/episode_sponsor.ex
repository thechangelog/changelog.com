defmodule Changelog.EpisodeSponsor do
  use Changelog.Web, :model

  alias Changelog.Regexp

  schema "episode_sponsors" do
    field :position, :integer
    field :title, :string
    field :link_url, :string
    field :description, :string


    belongs_to :episode, Changelog.Episode
    belongs_to :sponsor, Changelog.Sponsor

    timestamps()
  end

  @required_fields ~w(position title link_url)
  @optional_fields ~w(episode_id sponsor_id description)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:link_url, Regexp.http, message: Regexp.http_message)
  end

  def by_position do
    from p in __MODULE__, order_by: p.position
  end

  def newest_first(query) do
    from s in query, order_by: [desc: s.inserted_at]
  end
end
