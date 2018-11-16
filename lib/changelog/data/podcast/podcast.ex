defmodule Changelog.Podcast do
  use Changelog.Data

  alias Changelog.{Episode, EpisodeStat, Files, NewsItem, PodcastTopic,
                   PodcastHost, Regexp}

  require Logger

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
    field :partner, :boolean, default: false
    field :position, :integer
    field :subscribers, :map

    field :cover, Files.Cover.Type

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
      status: :published,
      description: "Master feed of all Changelog podcasts",
      keywords: "changelog, open source, oss, software, development, developer, hacker",
      itunes_url: "https://itunes.apple.com/us/podcast/changelog-master-feed/id1164554936",
      cover: true,
      hosts: []
    }
  end

  def file_changeset(podcast, attrs \\ %{}), do: cast_attachments(podcast, attrs, [:cover])

  def insert_changeset(podcast, attrs \\ %{}) do
    podcast
    |> cast(attrs, ~w(name slug status vanity_domain schedule_note description extended_description keywords twitter_handle itunes_url ping_url recorded_live partner position)a)
    |> validate_required([:name, :slug, :status])
    |> validate_format(:vanity_domain, Regexp.http, message: Regexp.http_message)
    |> validate_format(:itunes_url, Regexp.http, message: Regexp.http_message)
    |> validate_format(:ping_url, Regexp.http, message: Regexp.http_message)
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:slug)
    |> cast_assoc(:podcast_topics)
    |> cast_assoc(:podcast_hosts)
  end

  def update_changeset(podcast, attrs \\ %{}) do
    podcast
    |> insert_changeset(attrs)
    |> file_changeset(attrs)
  end

  def active(query \\ __MODULE__), do: from(q in query, where: q.status in [^:soon, ^:published])
  def public(query \\ __MODULE__), do: from(q in query, where: q.status in [^:soon, ^:published, ^:retired])
  def retired(query \\ __MODULE__), do: from(q in query, where: q.status == ^:retired)
  def not_retired(query \\ __MODULE__), do: from(q in query, where: q.status != ^:retired)
  def ours(query \\ __MODULE__), do: from(q in query, where: not(q.partner))
  def partners(query \\ __MODULE__), do: from(q in query, where: q.partner)
  def oldest_first(query \\ __MODULE__), do: from(q in query, order_by: [asc: q.id])
  def retired_last(query \\ __MODULE__), do: from(q in query, order_by: [asc: q.status])

  def get_by_slug!("master"), do: master()
  def get_by_slug!(slug) do
    public()
    |> Repo.get_by!(slug: slug)
    |> preload_hosts
  end

  def get_episodes(%{slug: "master"}), do: from(e in Episode)
  def get_episodes(podcast), do: assoc(podcast, :episodes)

  def get_news_items(%{slug: "master"}), do: NewsItem.with_object(NewsItem.audio)
  def get_news_items(podcast), do: NewsItem.with_object_prefix(NewsItem.audio, podcast.slug)

  def episode_count(podcast) do
    podcast
    |> assoc(:episodes)
    |> Repo.count
  end

  def has_feed(podcast), do: podcast.slug != "backstage"

  def is_master(podcast), do: podcast.slug == "master"

  def published_episode_count(%{slug: "master"}), do: Repo.count(Episode.published)
  def published_episode_count(podcast) do
    podcast
    |> assoc(:episodes)
    |> Episode.published
    |> Repo.count
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

  def preload_episode_stats(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :episode_stats)
  def preload_episode_stats(podcast), do: Repo.preload(podcast, :episode_stats)

  def preload_hosts(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(podcast_hosts: ^PodcastHost.by_position)
    |> Ecto.Query.preload(:hosts)
  end
  def preload_hosts(podcast) do
    podcast
    |> Repo.preload(podcast_hosts: {PodcastHost.by_position, :person})
    |> Repo.preload(:hosts)
  end

  def preload_topics(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(podcast_topics: ^PodcastTopic.by_position)
    |> Ecto.Query.preload(:topics)
  end
  def preload_topics(podcast) do
    podcast
    |> Repo.preload(podcast_topics: {PodcastTopic.by_position, :topic})
    |> Repo.preload(:topics)
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

  def update_subscribers(%{slug: "master"}, client, count) do
    podcast = get_by_slug!("backstage")
    update_subscribers(podcast, client, count)
  end
  def update_subscribers(podcast = %{subscribers: nil}, client, count) do
    podcast
    |> Map.put(:subscribers, %{})
    |> update_subscribers(client, count)
  end
  def update_subscribers(podcast, client, count) do
    new_subscribers = Map.put(podcast.subscribers, client, count)

    podcast
    |> change(%{subscribers: new_subscribers})
    |> Repo.update!
  end
end
