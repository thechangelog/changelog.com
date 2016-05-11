defmodule Changelog.EpisodeLink do
  use Changelog.Web, :model

  alias Changelog.Regexp

  schema "episode_links" do
    field :title, :string
    field :url, :string
    field :position, :integer
    field :delete, :boolean, virtual: true

    belongs_to :episode, Changelog.Episode

    timestamps
  end

  @required_fields ~w(title url position)
  @optional_fields ~w(episode_id delete)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:url, Regexp.http, message: Regexp.http_message)
    |> mark_for_deletion()
  end

  def by_position do
    from p in __MODULE__, order_by: p.position
  end

  defp mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
