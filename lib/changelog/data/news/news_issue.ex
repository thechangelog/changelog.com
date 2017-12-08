defmodule Changelog.NewsIssue do
  use Changelog.Data

  alias Changelog.{NewsItem, NewsIssueItem, NewsIssueAd, Regexp}

  schema "news_issues" do
    field :slug, :string
    field :note, :string

    field :published, :boolean, default: false
    field :published_at, Timex.Ecto.DateTime

    has_many :news_issue_ads, NewsIssueAd, foreign_key: :issue_id, on_delete: :delete_all
    has_many :ads, through: [:news_issue_ads, :ad]
    has_many :news_issue_items, NewsIssueItem, foreign_key: :issue_id, on_delete: :delete_all
    has_many :items, through: [:news_issue_items, :item]

    timestamps()
  end

  def admin_changeset(issue, attrs \\ %{}) do
    issue
    |> cast(attrs, ~w(slug note published published_at))
    |> validate_required([:slug])
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:slug)
    |> cast_assoc(:news_issue_ads)
    |> cast_assoc(:news_issue_items)
  end

  def newest_first(query \\ __MODULE__, field \\ :published_at), do: from(q in query, order_by: [desc: ^field])
  def with_numbered_slug(query \\ __MODULE__), do: from(q in query, where: fragment("slug ~ E'^\\\\d+$'"))
  def published(query \\ __MODULE__), do: from(q in query, where: q.published == true)
  def unpublished(query \\ __MODULE__), do: from(q in query, where: q.published == false)

  def preload_all(issue) do
    issue |> preload_ads |> preload_items
  end

  def preload_ads(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(news_issue_ads: ^NewsIssueAd.by_position)
    |> Ecto.Query.preload(:ads)
  end
  def preload_ads(issue) do
    issue
    |> Repo.preload(news_issue_ads: {NewsIssueAd.by_position, :ad})
    |> Repo.preload(:ads)
  end

  def preload_items(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(news_issue_items: ^NewsIssueItem.by_position)
    |> Ecto.Query.preload(:items)
  end
  def preload_items(issue) do
    issue
    |> Repo.preload(news_issue_items: {NewsIssueItem.by_position, :item})
    |> Repo.preload(:items)
  end

  def ad_count(issue) do
    Repo.count(from(q in NewsIssueAd, where: q.issue_id == ^issue.id))
  end

  def item_count(issue) do
    Repo.count(from(q in NewsIssueItem, where: q.issue_id == ^issue.id))
  end

  def is_published(issue), do: issue.published

  def is_publishable(issue), do: is_integer(issue.id) && !is_published(issue)
end
