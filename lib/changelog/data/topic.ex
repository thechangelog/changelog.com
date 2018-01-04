defmodule Changelog.Topic do
  use Changelog.Data

  alias Changelog.{EpisodeTopic, Files, NewsItemTopic, PostTopic, Regexp}

  schema "topics" do
    field :name, :string
    field :slug, :string
    field :description, :string

    field :icon, Files.Icon.Type

    has_many :episode_topics, EpisodeTopic, on_delete: :delete_all
    has_many :episodes, through: [:episode_topics, :episode]
    has_many :news_item_topics, NewsItemTopic, on_delete: :delete_all
    has_many :news_items, through: [:news_item_topics, :news_item]
    has_many :post_topics, PostTopic, on_delete: :delete_all
    has_many :posts, through: [:post_topics, :post]

    timestamps()
  end

  def file_changeset(topic, attrs \\ %{}), do: cast_attachments(topic, attrs, ~w(icon))

  def insert_changeset(topic, attrs \\ %{}) do
    topic
    |> cast(attrs, ~w(name slug description))
    |> validate_required([:name, :slug])
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:slug)
  end

  def update_changeset(topic, attrs \\ %{}) do
    topic
    |> insert_changeset(attrs)
    |> file_changeset(attrs)
  end

  def episode_count(topic), do: count(topic, EpisodeTopic)
  def news_count(topic), do: count(topic, NewsItemTopic)
  def post_count(topic), do: count(topic, PostTopic)

  defp count(topic, module), do: Repo.count(from(q in module, where: q.topic_id == ^topic.id))
end
