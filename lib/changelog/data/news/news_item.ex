defmodule Changelog.NewsItem do
  use Changelog.Data

  alias Changelog.{NewsSource, Person, Regexp}

  defenum Status, queued: 0, submitted: 1, declined: 2, published: 3
  defenum Type, link: 0, audio: 1, video: 2, project: 3, announcement: 4

  schema "news_items" do
    field :status, Status
    field :type, Type

    field :url, :string
    field :headline, :string
    field :story, :string
    # field :image, Icon.Type

    field :published_at, DateTime

    belongs_to :author, Person
    belongs_to :source, NewsSource

    timestamps()
  end

  def admin_changeset(news_item, attrs \\ %{}) do
    news_item
    # |> cast_attachments(attrs, ~w(image))
    |> cast(attrs, ~w(status type url headline story published_at author_id source_id))
    |> validate_required([:type, :url, :headline, :author_id])
    |> validate_format(:url, Regexp.http, message: Regexp.http_message)
  end

  def preload_all(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(:author)
    |> Ecto.Query.preload(:source)
  end

  def preload_all(news_item) do
    news_item
    |> Repo.preload(:author)
    |> Repo.preload(:source)
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
