defmodule Changelog.Topic do
  use Changelog.Data

  alias Changelog.{EpisodeTopic, Files, NewsItemTopic, PostTopic, Regexp}

  schema "topics" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :website, :string
    field :twitter_handle, :string

    field :icon, Files.Icon.Type

    has_many :episode_topics, EpisodeTopic, on_delete: :delete_all
    has_many :episodes, through: [:episode_topics, :episode]
    has_many :news_item_topics, NewsItemTopic, on_delete: :delete_all
    has_many :news_items, through: [:news_item_topics, :news_item]
    has_many :post_topics, PostTopic, on_delete: :delete_all
    has_many :posts, through: [:post_topics, :post]

    timestamps()
  end

  def with_news_items(query \\ __MODULE__) do
    from(q in query,
      distinct: true,
      left_join: i in assoc(q, :news_item_topics),
      where: not(is_nil(i.id)))
  end

  def file_changeset(topic, attrs \\ %{}), do: cast_attachments(topic, attrs, [:icon], allow_urls: true)

  def insert_changeset(topic, attrs \\ %{}) do
    topic
    |> cast(attrs, ~w(name slug description twitter_handle website)a)
    |> validate_required([:name, :slug])
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> validate_format(:website, Regexp.http, message: Regexp.http_message)
    |> unique_constraint(:slug)
    |> unique_constraint(:twitter_handle)
  end

  def update_changeset(topic, attrs \\ %{}) do
    topic
    |> insert_changeset(attrs)
    |> file_changeset(attrs)
  end

  def preload_news_items(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(news_item_topics: ^NewsItemTopic.by_position)
    |> Ecto.Query.preload(:news_items)
  end
  def preload_news_items(topic) do
    topic
    |> Repo.preload(news_item_topics: {NewsItemTopic.by_position, :news_item})
    |> Repo.preload(:news_items)
  end

  def episode_count(topic), do: Repo.count(from(q in EpisodeTopic, where: q.topic_id == ^topic.id))
  def news_count(topic), do: Repo.count(from(q in NewsItemTopic, where: q.topic_id == ^topic.id,  join: i in assoc(q, :news_item), where: i.status == ^:published))
  def post_count(topic), do: Repo.count(from(q in PostTopic, where: q.topic_id == ^topic.id))
end
