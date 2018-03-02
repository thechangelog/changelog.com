defmodule Changelog.NewsItem do
  use Changelog.Data, default_sort: :published_at

  alias Changelog.{Episode, Files, NewsItemTopic, NewsIssue, NewsQueue, NewsSource,
                   Person, Post, Regexp}

  defenum Status, declined: -1, draft: 0, queued: 1, submitted: 2, published: 3
  defenum Type, link: 0, audio: 1, video: 2, project: 3, announcement: 4

  schema "news_items" do
    field :status, Status, default: :draft
    field :type, Type

    field :url, :string
    field :headline, :string
    field :story, :string
    field :image, Files.Image.Type
    field :object_id, :string

    field :pinned, :boolean, default: false
    field :published_at, Timex.Ecto.DateTime

    field :impression_count, :integer, default: 0
    field :click_count, :integer, default: 0

    belongs_to :author, Person
    belongs_to :logger, Person
    belongs_to :source, NewsSource
    has_one :news_queue, NewsQueue, foreign_key: :item_id, on_delete: :delete_all
    has_many :news_item_topics, NewsItemTopic, foreign_key: :item_id, on_delete: :delete_all
    has_many :topics, through: [:news_item_topics, :topic]

    timestamps()
  end

  def audio(query \\ __MODULE__),                      do: from(q in query, where: q.type == ^:audio)
  def drafted(query \\ __MODULE__),                    do: from(q in query, where: q.status == ^:draft)
  def highest_ctr_first(query \\ __MODULE__),          do: from(q in query, order_by: fragment("click_count::float / NULLIF(impression_count, 0) desc nulls last"))
  def logged_by(query \\ __MODULE__, person),          do: from(q in query, where: q.logger_id == ^person.id)
  def published(query \\ __MODULE__),                  do: from(q in query, where: q.status == ^:published, where: q.published_at <= ^Timex.now)
  def pinned(query \\ __MODULE__),                     do: from(q in query, where: q.pinned)
  def unpinned(query \\ __MODULE__),                   do: from(q in query, where: not(q.pinned))
  def search(query, term),                             do: from(q in query, where: fragment("search_vector @@ plainto_tsquery('english', ?)", ^term))
  def with_episode(query \\ __MODULE__, episode),      do: from(q in query, where: q.object_id == ^"#{episode.podcast.slug}:#{episode.slug}")
  def with_object(query \\ __MODULE__),                do: from(q in query, where: not(is_nil(q.object_id)))
  def with_object_prefix(query \\ __MODULE__, prefix), do: from(q in query, where: like(q.object_id, ^"#{prefix}%"))
  def with_image(query \\ __MODULE__),                 do: from(q in query, where: not(is_nil(q.image)))
  def with_source(query \\ __MODULE__, source),        do: from(q in query, where: q.source_id == ^source.id)
  def with_topic(query \\ __MODULE__, topic),          do: from(q in query, join: t in assoc(q, :news_item_topics), where: t.topic_id == ^topic.id)
  def with_url(query \\ __MODULE__, url),              do: from(q in query, where: q.url == ^url)

  def published_since(query \\ __MODULE__, issue_or_time)
  def published_since(query, i = %NewsIssue{}),   do: from(q in query, where: q.status == ^:published, where: q.published_at >= ^i.published_at)
  def published_since(query, time = %DateTime{}), do: from(q in query, where: q.status == ^:published, where: q.published_at >= ^time)
  def published_since(query, _),                  do: published(query)

  def file_changeset(item, attrs \\ %{}) do
    cast_attachments(item, attrs, ~w(image), allow_urls: true)
  end

  def insert_changeset(item, attrs \\ %{}) do
    item
    |> cast(attrs, ~w(status type url headline story pinned published_at author_id logger_id object_id source_id))
    |> validate_required([:type, :url, :headline, :logger_id])
    |> validate_format(:url, Regexp.http, message: Regexp.http_message)
    |> foreign_key_constraint(:author_id)
    |> foreign_key_constraint(:logger_id)
    |> foreign_key_constraint(:source_id)
    |> cast_assoc(:news_item_topics)
  end

  def update_changeset(item, attrs \\ %{}) do
    item
    |> insert_changeset(attrs)
    |> file_changeset(attrs)
  end

  def load_object(item) do
    object = case item.type do
      :audio -> load_episode_object(item.object_id)
      _else -> load_post_object(item.object_id)
    end

    Map.put(item, :object, object)
  end

  defp load_episode_object(object_id) when is_nil(object_id), do: nil
  defp load_episode_object(object_id) do
    [p, e] = String.split(object_id, ":")
    Episode.published
    |> Episode.with_podcast_slug(p)
    |> Episode.with_slug(e)
    |> Episode.preload_podcast
    |> Episode.preload_guests
    |> Repo.one
  end

  defp load_post_object(object_id) when is_nil(object_id), do: nil
  defp load_post_object(object_id) do
    [_, slug] = String.split(object_id, ":")
    Post.published
    |> Post.preload_all
    |> Repo.get_by!(slug: slug)
  end

  def preload_all(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(:author)
    |> Ecto.Query.preload(:logger)
    |> Ecto.Query.preload(:source)
    |> preload_topics()
  end

  def preload_all(item) do
    item
    |> Repo.preload(:author)
    |> Repo.preload(:logger)
    |> Repo.preload(:source)
    |> preload_topics()
  end

  def preload_topics(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(news_item_topics: ^NewsItemTopic.by_position)
    |> Ecto.Query.preload(:topics)
  end
  def preload_topics(item) do
    item
    |> Repo.preload(news_item_topics: {NewsItemTopic.by_position, :topic})
    |> Repo.preload(:topics)
  end

  def queue!(item), do: item |> change(%{status: :queued}) |> Repo.update!
  def publish!(item), do: item |> change(%{status: :published, published_at: Timex.now}) |> Repo.update!

  def is_audio(item), do: item.type == :audio
  def is_video(item), do: item.type == :video
  def is_draft(item), do: item.status == :draft
  def is_published(item), do: item.status == :published

  def track_click(item) do
    item
    |> change(%{click_count: item.click_count + 1})
    |> Repo.update!
  end

  def track_impression(item) do
    item
    |> change(%{impression_count: item.impression_count + 1})
    |> Repo.update!
  end

  def latest_news_items do
    __MODULE__
    |> published
    |> newest_first
    |> preload_all
    |> limit(50)
    |> Repo.all
    |> Enum.map(&load_object/1)
  end
end
