defmodule Changelog.NewsItemComment do
  use Changelog.Data

  alias Changelog.{NewsItem, Person}

  schema "news_item_comments" do
    field :content, :string

    field :edited_at, Timex.Ecto.DateTime
    field :deleted_at, Timex.Ecto.DateTime

    belongs_to :news_item, NewsItem, foreign_key: :item_id
    belongs_to :author, Person
    belongs_to :parent, __MODULE__, foreign_key: :parent_id
    has_many :children, __MODULE__, foreign_key: :parent_id

    timestamps()
  end

  def insert_changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, ~w(content))
    |> validate_required([:content])
  end

  def nested(nil), do: []
  def nested([]), do: []
  def nested(comments) do
    comments
    |> Enum.map(&(Map.put(&1, :children, [])))
    |> Enum.reverse()
    |> Enum.reduce(%{}, fn(comment, map) ->
      comment = %{comment | children: Map.get(map, comment.id, [])}
      Map.update(map, comment.parent_id, [comment], fn(comments) -> [comment | comments] end)
    end)
    |> Map.get(nil)
  end

  def preload_all(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(:author)
  end

  def preload_all(comment) do
    comment
    |> Repo.preload(:author)
  end
end
