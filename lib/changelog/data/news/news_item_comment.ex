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
end
