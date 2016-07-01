defmodule Changelog.Podcast do
  use Changelog.Web, :model
  use Arc.Ecto.Schema

  alias Changelog.Regexp

  schema "podcasts" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :vanity_domain, :string
    field :keywords, :string
    field :twitter_handle, :string
    field :itunes_url, :string
    field :cover_art, Changelog.CoverArt.Type

    has_many :episodes, Changelog.Episode, on_delete: :delete_all
    has_many :podcast_hosts, Changelog.PodcastHost, on_delete: :delete_all
    has_many :hosts, through: [:podcast_hosts, :person]

    timestamps
  end

  @required_fields ~w(name slug)
  @optional_fields ~w(vanity_domain description keywords twitter_handle itunes_url)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_attachments(params, ~w(cover_art))
    |> validate_format(:vanity_domain, Regexp.http, message: Regexp.http_message)
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:slug)
    |> cast_assoc(:podcast_hosts, required: true)
  end

  def episode_count(podcast) do
    Repo.one from(e in Changelog.Episode,
      where: e.podcast_id == ^podcast.id,
      select: count(e.id))
  end

  def last_numbered_slug(podcast) do
    Repo.preload(podcast, :episodes).episodes
    |> Enum.sort_by(&(&1.id))
    |> Enum.reverse
    |> Enum.map(&(Float.parse(&1.slug)))
    |> Enum.find(fn(x) -> x != :error end)
  end
end
