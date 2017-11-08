defmodule Changelog.NewsItem do
  use Changelog.Data

  alias Changelog.{Files, NewsItemTopic, NewsQueue, NewsSource, Person, Regexp, Sponsor}

  defenum Status, queued: 0, submitted: 1, declined: 2, published: 3
  defenum Type, link: 0, audio: 1, video: 2, project: 3, announcement: 4

  schema "news_items" do
    field :status, Status
    field :type, Type

    field :url, :string
    field :headline, :string
    field :story, :string
    field :image, Files.Image.Type

    field :published_at, DateTime
    field :newsletter, :boolean, default: true

    belongs_to :author, Person
    belongs_to :logger, Person
    belongs_to :source, NewsSource
    has_one :news_queue, NewsQueue, foreign_key: :item_id, on_delete: :delete_all
    has_many :news_item_topics, NewsItemTopic, foreign_key: :item_id, on_delete: :delete_all
    has_many :topics, through: [:news_item_topics, :topic]

    timestamps()
  end

  def file_changeset(news_item, attrs \\ %{}) do
    cast_attachments(news_item, attrs, ~w(image))
  end

  def insert_changeset(news_item, attrs \\ %{}) do
    news_item
    |> cast(attrs, ~w(status type url headline story published_at newsletter author_id logger_id source_id))
    |> validate_required([:type, :url, :headline, :logger_id])
    |> validate_format(:url, Regexp.http, message: Regexp.http_message)
    |> foreign_key_constraint(:author_id)
    |> foreign_key_constraint(:logger_id)
    |> foreign_key_constraint(:source_id)
    |> cast_assoc(:news_item_topics)
  end

  def update_changeset(news_item, attrs \\ %{}) do
    news_item
    |> insert_changeset(attrs)
    |> file_changeset(attrs)
  end

  def preload_all(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(:author)
    |> Ecto.Query.preload(:logger)
    |> Ecto.Query.preload(:source)
    |> preload_topics
  end

  def preload_all(news_item) do
    news_item
    |> Repo.preload(:author)
    |> Repo.preload(:logger)
    |> Repo.preload(:source)
    |> preload_topics
  end

  def preload_topics(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(news_item_topics: ^NewsItemTopic.by_position)
    |> Ecto.Query.preload(:topics)
  end

  def preload_topics(news_item) do
    news_item
    |> Repo.preload(news_item_topics: {NewsItemTopic.by_position, :topic})
    |> Repo.preload(:topics)
  end

  def publish!(news_item) do
    news_item
    |> change(%{status: :published, published_at: Timex.now})
    |> Repo.update!
  end

  def published(query \\ __MODULE__) do
    from p in query,
      where: p.status == ^:published
  end

  def is_published(news_item) do
    news_item.status == :published
  end

  def newest_first(query \\ __MODULE__, field \\ :published_at) do
    from q in query, order_by: [desc: ^field]
  end
end
