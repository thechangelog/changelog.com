defmodule Changelog.NewsItemTopic do
  use Changelog.Data

  alias Changelog.{NewsItem, Topic}

  schema "news_item_topics" do
    field :position, :integer
    field :delete, :boolean, virtual: true

    belongs_to :news_item, NewsItem, foreign_key: :item_id
    belongs_to :topic, Topic

    timestamps()
  end

  def changeset(item_topic, params \\ %{}) do
    item_topic
    |> cast(params, ~w(position item_id topic_id delete)a)
    |> validate_required([:position])
    |> mark_for_deletion()
  end

  def build_and_preload({topic, position}) do
    %__MODULE__{position: position, topic_id: topic.id} |> Repo.preload(:topic)
  end
end
