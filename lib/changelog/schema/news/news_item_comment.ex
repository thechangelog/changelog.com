defmodule Changelog.NewsItemComment do
  use Changelog.Schema

  alias Changelog.{NewsItem, Person, StringKit}

  schema "news_item_comments" do
    field :content, :string

    field :approved, :boolean, default: false

    field :edited_at, :utc_datetime
    field :deleted_at, :utc_datetime

    belongs_to :news_item, NewsItem, foreign_key: :item_id
    belongs_to :author, Person
    belongs_to :parent, __MODULE__, foreign_key: :parent_id
    has_many :children, __MODULE__, foreign_key: :parent_id

    timestamps()
  end

  def replies(query \\ __MODULE__), do: from(q in query, where: not is_nil(q.parent_id))

  def insert_changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, ~w(content author_id item_id parent_id approved)a)
    |> validate_required([:content, :author_id, :item_id])
    |> foreign_key_constraint(:author_id)
    |> foreign_key_constraint(:item_id)
    |> foreign_key_constraint(:parent_id)
  end

  def update_changeset(struct, attrs \\ %{}) do
    insert_changeset(struct, attrs)
  end

  def mentioned_people(%__MODULE__{content: content}), do: mentioned_people(content)

  def mentioned_people(content) do
    content
    |> StringKit.extract_mentions()
    |> get_mentioned_people()
  end

  defp get_mentioned_people([]), do: []

  defp get_mentioned_people(handles) do
    handles
    |> Person.with_handles()
    |> Repo.all()
  end

  # Expects newest comments first
  def nested(nil), do: []
  def nested([]), do: []

  def nested(comments) do
    comments
    |> Enum.map(&Map.put(&1, :children, []))
    |> Enum.reduce(%{}, fn comment, map ->
      comment = %{comment | children: Map.get(map, comment.id, [])}
      Map.update(map, comment.parent_id, [comment], fn comments -> [comment | comments] end)
    end)
    |> Map.get(nil)
    # TODO: This should be part of an Ecto Query instead
    |> Enum.filter(fn %__MODULE__{approved: approved} ->
      approved
    end)
  end

  def preload_author(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :author)
  def preload_author(comment), do: Repo.preload(comment, :author)

  def preload_children(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :children)
  def preload_children(comment), do: Repo.preload(comment, :children)

  def preload_news_item(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :news_item)
  def preload_news_item(comment), do: Repo.preload(comment, :news_item)

  def preload_parent(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :parent)
  def preload_parent(comment), do: Repo.preload(comment, :parent)

  def preload_all(query_or_comment) do
    query_or_comment
    |> preload_author()
    |> preload_news_item()
    |> preload_parent()
    |> preload_children()
  end

  def refresh_news_item(comment) do
    comment
    |> preload_news_item()
    |> Map.get(:news_item)
    |> change(refreshed_at: now_in_seconds())
    |> Repo.update()
  end
end
