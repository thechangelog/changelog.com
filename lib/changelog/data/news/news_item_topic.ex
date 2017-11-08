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

  def changeset(news_item_topic, params \\ %{}) do
    news_item_topic
    |> cast(params, ~w(position item_id topic_id delete))
    |> validate_required([:position])
    |> mark_for_deletion()
  end

  def by_position do
    from p in __MODULE__, order_by: p.position
  end

  def build_and_preload({topic, position}) do
    %__MODULE__{position: position, topic_id: topic.id} |> Repo.preload(:topic)
  end

  defp mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
