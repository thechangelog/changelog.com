defmodule Changelog.Topic do
  use Changelog.Data

  alias Changelog.{EpisodeTopic, NewsItemTopic, PostTopic, Regexp}

  schema "topics" do
    field :name, :string
    field :slug, :string
    field :description, :string

    has_many :episode_topics, EpisodeTopic, on_delete: :delete_all
    has_many :episodes, through: [:episode_topics, :episode]
    has_many :news_item_topics, NewsItemTopic, on_delete: :delete_all
    has_many :news_items, through: [:news_item_topics, :news_item]
    has_many :post_topics, PostTopic, on_delete: :delete_all
    has_many :posts, through: [:post_topics, :post]

    timestamps()
  end

  def admin_changeset(topic, params \\ %{}) do
    topic
    |> cast(params, ~w(name slug description))
    |> validate_required([:name, :slug])
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:slug)
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

  def episode_count(topic) do
    Repo.count(from(e in EpisodeTopic, where: e.topic_id == ^topic.id))
  end

  def news_count(topic) do
    Repo.count(from(e in NewsItemTopic, where: e.topic_id == ^topic.id))
  end

  def post_count(topic) do
    Repo.count(from(p in PostTopic, where: p.topic_id == ^topic.id))
  end
end
