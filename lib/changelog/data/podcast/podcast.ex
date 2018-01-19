defmodule Changelog.Podcast do
  use Changelog.Data

  alias Changelog.{Episode, EpisodeStat, NewsItem, PodcastTopic, PodcastHost, Regexp}

  defenum Status, draft: 0, soon: 1, published: 2, retired: 3

  schema "podcasts" do
    field :name, :string
    field :slug, :string
    field :status, Status
    field :description, :string
    field :extended_description, :string
    field :vanity_domain, :string
    field :keywords, :string
    field :twitter_handle, :string
    field :itunes_url, :string
    field :ping_url, :string
    field :schedule_note, :string
    field :download_count, :float
    field :reach_count, :integer
    field :recorded_live, :boolean, default: false

    has_many :episodes, Episode, on_delete: :delete_all
    has_many :podcast_topics, PodcastTopic, on_delete: :delete_all
    has_many :topics, through: [:podcast_topics, :topic]
    has_many :podcast_hosts, PodcastHost, on_delete: :delete_all
    has_many :hosts, through: [:podcast_hosts, :person]
    has_many :episode_stats, EpisodeStat

    timestamps()
  end

  def master do
  %__MODULE__{
    name: "Changelog Master Feed",
    slug: "master",
    description: "The master feed of all Changelog podcasts. <br><code>git pull changelog master</code>",
    keywords: "changelog, open source, oss, software, development, developer, hacker",
    itunes_url: "https://itunes.apple.com/us/podcast/changelog-master-feed/id1164554936",
    hosts: []
  }
  end

  def admin_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(name slug status vanity_domain schedule_note description extended_description keywords twitter_handle itunes_url ping_url recorded_live))
    |> validate_required([:name, :slug, :status])
    |> validate_format(:vanity_domain, Regexp.http, message: Regexp.http_message)
    |> validate_format(:itunes_url, Regexp.http, message: Regexp.http_message)
    |> validate_format(:ping_url, Regexp.http, message: Regexp.http_message)
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:slug)
    |> cast_assoc(:podcast_topics)
    |> cast_assoc(:podcast_hosts)
  end

  def public(query \\ __MODULE__) do
    from(p in query, where: p.status in [^:soon, ^:published])
  end

  def oldest_first(query \\ __MODULE__) do
    from p in query, order_by: [asc: p.id]
  end

  def get_by_slug(slug) do
    if slug == "master" do
      master()
    else
      public()
      |> Repo.get_by!(slug: slug)
      |> preload_hosts
    end
  end

  def get_episodes(podcast) do
    if is_master(podcast) do
      from(e in Episode)
    else
      assoc(podcast, :episodes)
    end
  end

  def get_news_items(podcast) do
    if is_master(podcast) do
      NewsItem.with_object(NewsItem.audio)
    else
      NewsItem.with_object_prefix(NewsItem.audio, podcast.slug)
    end
  end

  def episode_count(podcast) do
    podcast
    |> assoc(:episodes)
    |> Repo.count
  end

  def is_master(podcast) do
    podcast.slug == "master"
  end

  def published_episode_count(podcast) do
    query = if is_master(podcast) do
      Episode.published
    else
      podcast
      |> assoc(:episodes)
      |> Episode.published
    end

    Repo.count(query)
  end

  def last_numbered_slug(podcast) do
    Repo.preload(podcast, :episodes).episodes
    |> Enum.map(fn(x) ->
      case Integer.parse(x.slug) do
        {int, _remainder} -> int
        :error -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.max(fn -> 0 end)
  end

  def latest_episode(podcast) do
    podcast
    |> assoc(:episodes)
    |> Episode.published
    |> Episode.newest_first
    |> Ecto.Query.first
    |> Repo.one
  end

  def preload_topics(podcast) do
    podcast
    |> Repo.preload(podcast_topics: {PodcastTopic.by_position, :topic})
    |> Repo.preload(:topics)
  end

  def preload_hosts(podcast) do
    podcast
    |> Repo.preload(podcast_hosts: {PodcastHost.by_position, :person})
    |> Repo.preload(:hosts)
  end

  def update_stat_counts(podcast) do
    episodes = Repo.all(assoc(podcast, :episodes))

    new_downloads =
      episodes
      |> Enum.map(&(&1.download_count))
      |> Enum.sum
      |> Kernel./(1)
      |> Float.round(2)

    new_reach =
      episodes
      |> Enum.map(&(&1.reach_count))
      |> Enum.sum

    podcast
    |> change(%{download_count: new_downloads, reach_count: new_reach})
    |> Repo.update!
  end
end
