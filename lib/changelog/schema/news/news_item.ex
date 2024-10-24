defmodule Changelog.NewsItem do
  use Changelog.Schema, default_sort: :published_at

  require Logger

  alias Changelog.{
    Episode,
    Files,
    NewsItemComment,
    NewsItemTopic,
    NewsIssue,
    NewsQueue,
    NewsSource,
    Person,
    Post,
    Regexp,
    Subscription,
    UrlKit
  }

  defenum(Status, declined: -1, draft: 0, queued: 1, submitted: 2, published: 3, accepted: 4)
  defenum(Type, link: 0, audio: 1, video: 2, project: 3, announcement: 4, post: 5)

  schema "news_items" do
    field :status, Status, default: :draft
    field :type, Type

    field :url, :string
    field :headline, :string
    field :story, :string
    field :image, Files.Image.Type
    field :object_id, :string
    field :object, :map, virtual: true

    field :feed_only, :boolean, default: false
    field :pinned, :boolean, default: false

    field :published_at, :utc_datetime
    field :refreshed_at, :utc_datetime

    field :impression_count, :integer, default: 0
    field :click_count, :integer, default: 0

    field :message, :string, default: ""

    belongs_to :author, Person
    belongs_to :logger, Person
    belongs_to :submitter, Person
    belongs_to :source, NewsSource
    has_one :news_queue, NewsQueue, foreign_key: :item_id

    has_many :news_item_topics, NewsItemTopic, foreign_key: :item_id, on_replace: :delete

    has_many :topics, through: [:news_item_topics, :topic]
    has_many :comments, NewsItemComment, foreign_key: :item_id
    has_many :subscriptions, Subscription, where: [unsubscribed_at: nil], foreign_key: :item_id

    timestamps()
  end

  def audio(query \\ __MODULE__), do: from(q in query, where: q.type == ^:audio)
  def non_audio(query \\ __MODULE__), do: from(q in query, where: q.type != ^:audio)

  def by_ids(query \\ __MODULE__, ids),
    do:
      from(q in query, where: q.id in ^ids, order_by: fragment("array_position(?, ?)", ^ids, q.id))

  def feed_only(query \\ __MODULE__), do: from(q in query, where: q.feed_only)
  def non_feed_only(query \\ __MODULE__), do: from(q in query, where: not q.feed_only)

  def accepted(query \\ __MODULE__), do: from(q in query, where: q.status == ^:accepted)
  def declined(query \\ __MODULE__), do: from(q in query, where: q.status == ^:declined)
  def drafted(query \\ __MODULE__), do: from(q in query, where: q.status == ^:draft)

  def logged_by(query \\ __MODULE__, person),
    do: from(q in query, where: q.logger_id == ^person.id)

  def post(query \\ __MODULE__), do: from(q in query, where: q.type == ^:post)
  def non_post(query \\ __MODULE__), do: from(q in query, where: q.type != ^:post)

  def published(query \\ __MODULE__),
    do: from(q in query, where: q.status == ^:published, where: q.published_at <= ^Timex.now())

  def pinned(query \\ __MODULE__), do: from(q in query, where: q.pinned)
  def unpinned(query \\ __MODULE__), do: from(q in query, where: not q.pinned)

  def search(query, term),
    do: from(q in query, where: fragment("search_vector @@ plainto_tsquery('english', ?)", ^term))

  def similar_to(query \\ __MODULE__, item),
    do:
      from(q in query,
        where: q.id != ^item.id,
        where: ilike(q.url, ^"%#{UrlKit.sans_scheme(item.url)}%")
      )

  def similar_url(query \\ __MODULE__, url),
    do: from(q in query, where: ilike(q.url, ^"%#{UrlKit.sans_scheme(url)}%"))

  def submitted(query \\ __MODULE__), do: from(q in query, where: q.status == ^:submitted)
  def with_author(query \\ __MODULE__), do: from(q in query, where: not is_nil(q.author_id))

  def with_episode(query \\ __MODULE__, episode),
    do: from(q in query, where: q.object_id == ^Episode.object_id(episode))

  def with_episodes(query \\ __MODULE__, episodes),
    do: from(q in query, where: q.object_id in ^Enum.map(episodes, &Episode.object_id/1))

  def with_person(query \\ __MODULE__, person),
    do: from(q in query, where: fragment("submitter_id=? or author_id=?", ^person.id, ^person.id))

  def with_post(query \\ __MODULE__, post),
    do: from(q in query, where: q.object_id == ^"posts:#{post.slug}")

  def with_object(query \\ __MODULE__), do: from(q in query, where: not is_nil(q.object_id))
  def sans_object(query \\ __MODULE__), do: from(q in query, where: is_nil(q.object_id))

  def with_object_prefix(query \\ __MODULE__, prefix),
    do: from(q in query, where: like(q.object_id, ^"#{prefix}:%"))

  def with_image(query \\ __MODULE__), do: from(q in query, where: not is_nil(q.image))

  def with_source(query \\ __MODULE__, source),
    do: from(q in query, where: q.source_id == ^source.id)

  def with_topic(query \\ __MODULE__, topic),
    do: from(q in query, join: t in assoc(q, :news_item_topics), where: t.topic_id == ^topic.id)

  def with_url(query \\ __MODULE__, url), do: from(q in query, where: q.url == ^url)

  def with_person_or_episodes(person, episodes) do
    person_query = with_person(person)
    episode_query = with_episodes(episodes)
    unioned_query = Ecto.Query.union(person_query, ^episode_query)
    from(q in Ecto.Query.subquery(unioned_query))
  end

  def published_since(query \\ __MODULE__, issue_or_time)

  def published_since(query, i = %NewsIssue{}),
    do: from(q in query, where: q.status == ^:published, where: q.published_at >= ^i.published_at)

  def published_since(query, time = %DateTime{}),
    do: from(q in query, where: q.status == ^:published, where: q.published_at >= ^time)

  def published_since(query, _), do: published(query)

  def freshest_first(query \\ __MODULE__), do: from(q in query, order_by: [desc: :refreshed_at])
  def top_clicked_first(query \\ __MODULE__), do: from(q in query, order_by: [desc: :click_count])

  def top_ctr_first(query \\ __MODULE__),
    do:
      from(q in query,
        order_by: fragment("click_count::float / NULLIF(impression_count, 0) desc nulls last")
      )

  def top_impressed_first(query \\ __MODULE__),
    do: from(q in query, order_by: [desc: :impression_count])

  def file_changeset(item, attrs \\ %{}),
    do: cast_attachments(item, attrs, [:image], allow_urls: true)

  def insert_changeset(item, attrs \\ %{}) do
    item
    |> cast(
      attrs,
      ~w(status type url headline story pinned published_at author_id logger_id submitter_id object_id source_id)a
    )
    |> validate_required([:type, :url, :headline, :logger_id])
    |> validate_format(:url, Regexp.http(), message: Regexp.http_message())
    |> foreign_key_constraint(:author_id)
    |> foreign_key_constraint(:logger_id)
    |> foreign_key_constraint(:source_id)
    |> cast_assoc(:news_item_topics)
  end

  def submission_changeset(item, attrs \\ %{}) do
    item
    |> cast(attrs, ~w(url headline story author_id submitter_id)a)
    |> validate_required([:type, :url, :headline, :submitter_id])
    |> validate_format(:url, Regexp.http(), message: Regexp.http_message())
  end

  def update_changeset(item, attrs \\ %{}) do
    item
    |> insert_changeset(attrs)
    |> file_changeset(attrs)
  end

  def slug(item) do
    item.headline
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s]/, "")
    |> String.trim()
    |> String.replace(~r/\s+/, "-")
    |> Kernel.<>("-#{hashid(item)}")
  end

  def load_object(item) do
    object =
      case item.type do
        :audio -> get_episode_object(item.object_id)
        :post -> get_post_object(item.object_id)
        :link -> get_news_object(item.object_id)
        _else -> nil
      end

    load_object(item, object)
  end

  def load_object(nil, _object), do: nil
  def load_object(item, object), do: Map.put(item, :object, object)

  def load_object_with_transcript(item = %{object_id: object_id}) do
    [_podcast_id, episode_id] = String.split(object_id, ":")

    episode =
      Episode
      |> Repo.get(episode_id)

    load_object(item, episode)
  end

  defp get_episode_object(nil), do: nil

  defp get_episode_object(object_id) do
    [_podcast_id, episode_id] = String.split(object_id, ":")

    Episode
    |> Episode.exclude_transcript()
    |> Episode.preload_podcast()
    |> Episode.preload_guests()
    |> Repo.get(episode_id)
  end

  # items that link to news objects are actually the same as items
  # that link to episode objects, but we differentiate them because
  # they are not audio, they are merely links that have been accepted
  # and included in a news episode/email
  defp get_news_object(object_id), do: get_episode_object(object_id)

  defp get_post_object(nil), do: nil

  defp get_post_object(object_id) do
    [_, slug] = String.split(object_id, ":")

    Post.published()
    |> Post.preload_all()
    |> Repo.get_by!(slug: slug)
  end

  def comment_count(item) do
    if Ecto.assoc_loaded?(item.comments) do
      length(item.comments)
    else
      Repo.count(from(q in NewsItemComment, where: q.item_id == ^item.id))
    end
  end

  def participants(item) do
    item = preload_all(item)

    [
      item.author,
      item.submitter,
      item.logger
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  def preload_all(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(:author)
    |> Ecto.Query.preload(:logger)
    |> Ecto.Query.preload(:submitter)
    |> preload_source()
    |> preload_topics()
  end

  def preload_all(item) do
    item
    |> Repo.preload(:author)
    |> Repo.preload(:logger)
    |> Repo.preload(:submitter)
    |> preload_source()
    |> preload_topics()
  end

  def preload_comments(query = %Ecto.Query{}) do
    Ecto.Query.preload(query, comments: ^NewsItemComment.newest_first())
  end

  def preload_comments(item) do
    Repo.preload(item, comments: {NewsItemComment.newest_first(), [:author]})
  end

  def preload_source(query = %Ecto.Query{}) do
    Ecto.Query.preload(query, :source)
  end

  def preload_source(item) do
    Repo.preload(item, :source)
  end

  def preload_topics(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(news_item_topics: ^NewsItemTopic.by_position())
    |> Ecto.Query.preload(:topics)
  end

  def preload_topics(item) do
    item
    |> Repo.preload(news_item_topics: {NewsItemTopic.by_position(), :topic})
    |> Repo.preload(:topics)
  end

  def accept!(item, object_id), do: accept!(item, object_id, "")

  def accept!(item, object_id, message) do
    item
    |> change(%{status: :accepted})
    |> change(%{message: message})
    |> change(%{object_id: "news:#{object_id}"})
    |> Repo.update!()
  end

  def decline!(item), do: item |> change(%{status: :declined}) |> Repo.update!()
  def decline!(item, ""), do: decline!(item)

  def decline!(item, message),
    do: item |> change(%{status: :declined, message: message}) |> Repo.update!()

  def queue!(item), do: item |> change(%{status: :queued}) |> Repo.update!()

  def publish!(item),
    do:
      item
      |> change(%{
        status: :published,
        published_at: item.published_at || now_in_seconds(),
        refreshed_at: now_in_seconds()
      })
      |> Repo.update!()

  def unpublish!(item),
    do: item |> change(%{status: :draft, published_at: nil, refreshed_at: nil}) |> Repo.update!()

  def is_audio(item), do: item.type == :audio
  def is_non_audio(item), do: item.type != :audio
  def is_post(item), do: item.type == :post
  def is_video(item), do: item.type == :video

  def is_draft(item), do: item.status == :draft
  def is_published(item), do: item.status == :published
  def is_queued(item), do: item.status == :queued

  def subscribe_participants(item = %{type: :audio}) do
    item
    |> load_object()
    |> Map.get(:object)
    |> Episode.participants()
    |> Enum.filter(& &1.settings.subscribe_to_participated_episodes)
    |> Enum.each(fn person ->
      Subscription.subscribe(person, item, "you were on this episode")
    end)
  end

  def subscribe_participants(item) do
    item
    |> participants()
    |> Enum.filter(& &1.settings.subscribe_to_contributed_news)
    |> Enum.each(fn person ->
      Subscription.subscribe(person, item, "you contributed to this news")
    end)
  end

  def track_click(item) do
    item
    |> change(%{click_count: item.click_count + 1})
    |> Repo.update!()
  end

  def track_impression(item) do
    item
    |> change(%{impression_count: item.impression_count + 1})
    |> Repo.update!()
  end

  def latest_news_items do
    __MODULE__
    |> published()
    |> newest_first()
    |> preload_all()
    |> limit(50)
    |> Repo.all()
    |> Enum.map(&load_object/1)
  end
end
