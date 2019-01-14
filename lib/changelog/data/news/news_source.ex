defmodule Changelog.NewsSource do
  use Changelog.Data

  alias Changelog.{Files, NewsItem, Regexp}

  schema "news_sources" do
    field :name, :string
    field :slug, :string
    field :website, :string
    field :twitter_handle, :string
    field :description, :string
    field :feed, :string
    field :regex, :string

    field :icon, Files.Icon.Type

    has_many :news_items, NewsItem, foreign_key: :source_id, on_delete: :nilify_all

    timestamps()
  end

  def with_news_items(query \\ __MODULE__) do
    from(q in query,
      distinct: true,
      left_join: i in assoc(q, :news_items),
      where: not(is_nil(i.id)))
  end

  def file_changeset(source, attrs \\ %{}), do: cast_attachments(source, attrs, [:icon], allow_urls: true)

  def insert_changeset(source, attrs \\ %{}) do
    source
    |> cast(attrs, ~w(name slug website twitter_handle description regex feed)a)
    |> validate_required([:name, :slug, :website])
    |> validate_format(:website, Regexp.http, message: Regexp.http_message)
    |> validate_format(:feed, Regexp.http, message: Regexp.http_message)
    |> unique_constraint(:slug)
    |> unique_constraint(:twitter_handle)
  end

  def update_changeset(source, attrs \\ %{}) do
    source
    |> insert_changeset(attrs)
    |> file_changeset(attrs)
  end

  def preload_news_items(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :news_items)
  def preload_news_items(source), do: Repo.preload(source, :news_items)

  def get_by_url(url) do
    try do
      matching(url)
      |> Repo.all
      |> List.first
    rescue
      Postgrex.Error -> nil
    end
  end

  def matching(url), do: from(s in __MODULE__, where: fragment("? ~* regex", ^url))

  def news_count(source), do: Repo.count(from(q in NewsItem, where: q.source_id == ^source.id, where: q.status == ^:published))
end
