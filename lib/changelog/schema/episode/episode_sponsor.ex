defmodule Changelog.EpisodeSponsor do
  use Changelog.Schema

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
    |> cast(params, ~w(position title link_url episode_id sponsor_id description delete)a)
    |> validate_required([:position, :title, :link_url])
    |> validate_format(:link_url, Regexp.http(), message: Regexp.http_message())
    |> foreign_key_constraint(:episode_id)
    |> foreign_key_constraint(:sponsor_id)
    |> mark_for_deletion()
  end

  def preload_episode(query = %Ecto.Query{}), do: Ecto.Query.preload(query, episode: :podcast)
  def preload_episode(sponsor), do: Repo.preload(sponsor, episode: :podcast)
end
