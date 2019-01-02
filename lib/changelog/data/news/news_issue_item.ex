defmodule Changelog.NewsIssueItem do
  use Changelog.Data

  alias Changelog.{NewsIssue, NewsItem}

  schema "news_issue_items" do
    field :position, :integer
    field :delete, :boolean, virtual: true

    belongs_to :item, NewsItem, foreign_key: :item_id
    belongs_to :issue, NewsIssue, foreign_key: :issue_id

    timestamps()
  end

  def changeset(issue_item, params \\ %{}) do
    issue_item
    |> cast(params, ~w(position item_id issue_id delete)a)
    |> validate_required([:position])
    |> mark_for_deletion()
  end

  def build_and_preload({item, position}) do
    %__MODULE__{position: position, item_id: item.id} |> Repo.preload(:item)
  end
end
