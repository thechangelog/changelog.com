defmodule Changelog.Channel do
  use Changelog.Data

  alias Changelog.{EpisodeChannel, PostChannel, Regexp}

  schema "channels" do
    field :name, :string
    field :slug, :string
    field :description, :string

    has_many :episode_channels, EpisodeChannel, on_delete: :delete_all
    has_many :episodes, through: [:episode_channels, :episode]
    has_many :post_channels, PostChannel, on_delete: :delete_all
    has_many :posts, through: [:post_channels, :post]

    timestamps()
  end

  def admin_changeset(channel, params \\ %{}) do
    channel
    |> cast(params, ~w(name slug description))
    |> validate_required([:name, :slug])
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:slug)
  end

  def episode_count(channel) do
    Repo.count(from(e in EpisodeChannel, where: e.channel_id == ^channel.id))
  end

  def post_count(channel) do
    Repo.count(from(p in PostChannel, where: p.channel_id == ^channel.id))
  end
end
