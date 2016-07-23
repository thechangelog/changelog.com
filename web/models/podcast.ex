defmodule Changelog.Podcast do
  use Changelog.Web, :model
  use Arc.Ecto.Schema

  alias Changelog.Regexp

  schema "podcasts" do
    field :name, :string
    field :slug, :string
    field :status, PodcastStatus
    field :description, :string
    field :vanity_domain, :string
    field :keywords, :string
    field :twitter_handle, :string
    field :itunes_url, :string
    field :schedule_note, :string

    has_many :episodes, Changelog.Episode, on_delete: :delete_all
    has_many :podcast_hosts, Changelog.PodcastHost, on_delete: :delete_all
    has_many :hosts, through: [:podcast_hosts, :person]

    timestamps
  end

  @required_fields ~w(name slug status)
  @optional_fields ~w(vanity_domain schedule_note description keywords twitter_handle itunes_url)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:vanity_domain, Regexp.http, message: Regexp.http_message)
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:slug)
    |> cast_assoc(:podcast_hosts)
  end

  def public(query \\ __MODULE__) do
    from(p in query, where: p.status in [^:soon, ^:published])
  end

  def oldest_first(query \\ __MODULE__) do
    from p in query, order_by: [asc: p.id]
  end

  def episode_count(podcast) do
    Repo.one from(e in Changelog.Episode,
      where: e.podcast_id == ^podcast.id,
      select: count(e.id))
  end

  def published_episode_count(podcast) do
    podcast
    |> assoc(:episodes)
    |> Changelog.Episode.published
    |> Ecto.Query.select([e], count(e.id))
    |> Repo.one
  end

  def last_numbered_slug(podcast) do
    Repo.preload(podcast, :episodes).episodes
    |> Enum.sort_by(&(&1.id))
    |> Enum.reverse
    |> Enum.map(&(Float.parse(&1.slug)))
    |> Enum.find(fn(x) -> x != :error end)
  end

  def preload_hosts(podcast) do
    podcast
    |> Repo.preload(podcast_hosts: {Changelog.PodcastHost.by_position, :person})
    |> Repo.preload(:hosts)
  end
end
