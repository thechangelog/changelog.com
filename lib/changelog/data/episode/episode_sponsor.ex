defmodule Changelog.EpisodeSponsor do
  use Changelog.Data

  alias Changelog.{Episode, Regexp, Sponsor}

  schema "episode_sponsors" do
    field :position, :integer
    field :title, :string
    field :link_url, :string
    field :description, :string

    field :delete, :boolean, virtual: true

    belongs_to :episode, Episode
    belongs_to :sponsor, Sponsor

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(position title link_url episode_id sponsor_id description delete))
    |> validate_required([:position, :title, :link_url])
    |> validate_format(:link_url, Regexp.http, message: Regexp.http_message)
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
