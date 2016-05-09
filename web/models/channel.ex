defmodule Changelog.Channel do
  use Changelog.Web, :model

  alias Changelog.Regexp

  schema "channels" do
    field :name, :string
    field :slug, :string
    field :description, :string

    has_many :episode_channels, Changelog.EpisodeChannel, on_delete: :delete_all
    has_many :episodes, through: [:episode_channels, :episode]

    timestamps
  end

  @required_fields ~w(name slug)
  @optional_fields ~w(description)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:slug)
  end

  def episode_count(channel) do
    Repo.one from(e in Changelog.EpisodeChannel,
      where: e.channel_id == ^channel.id,
      select: count(e.id))
  end
end
