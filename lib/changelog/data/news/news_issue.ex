defmodule Changelog.NewsIssue do
  use Changelog.Data, default_sort: :published_at

  alias Changelog.{NewsIssueItem, NewsIssueAd, Regexp}

  schema "news_issues" do
    field :slug, :string
    field :note, :string
    field :teaser, :string

    field :published, :boolean, default: false
    field :published_at, :utc_datetime

    has_many :news_issue_ads, NewsIssueAd, foreign_key: :issue_id, on_delete: :delete_all
    has_many :ads, through: [:news_issue_ads, :ad]
    has_many :news_issue_items, NewsIssueItem, foreign_key: :issue_id, on_delete: :delete_all
    has_many :items, through: [:news_issue_items, :item]

    timestamps()
  end

  def admin_changeset(issue, attrs \\ %{}) do
    issue
    |> cast(attrs, ~w(slug teaser note published published_at)a)
    |> validate_required([:slug])
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:slug)
    |> cast_assoc(:news_issue_ads)
    |> cast_assoc(:news_issue_items)
  end

  def with_numbered_slug(query \\ __MODULE__), do: from(q in query, where: fragment("slug ~ E'^\\\\d+$'"))
  def published(query \\ __MODULE__), do: from(q in query, where: q.published == true)
  def unpublished(query \\ __MODULE__), do: from(q in query, where: q.published == false)

  def next_slug(issue) when is_nil(issue), do: 1
  def next_slug(issue) do
    last_slug = case Integer.parse(issue.slug) do
      {int, _remainder} -> int
      :error -> 0
    end

    last_slug + 1
  end

  def preload_all(issue) do
    issue |> preload_ads |> preload_items
  end

  def preload_ads(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(news_issue_ads: ^NewsIssueAd.by_position)
    |> Ecto.Query.preload(ads: [sponsorship: [:sponsor]])
  end
  def preload_ads(issue) do
    issue
    |> Repo.preload(news_issue_ads: {NewsIssueAd.by_position, :ad})
    |> Repo.preload(ads: [sponsorship: [:sponsor]])
  end

  def preload_items(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(news_issue_items: ^NewsIssueItem.by_position)
    |> Ecto.Query.preload(items: [:author, :logger, :source, :submitter, :topics])
  end
  def preload_items(issue) do
    issue
    |> Repo.preload(news_issue_items: {NewsIssueItem.by_position, :item})
    |> Repo.preload(items: [:author, :logger, :source, :submitter, :topics])
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
