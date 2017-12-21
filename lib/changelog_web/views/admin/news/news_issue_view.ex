defmodule ChangelogWeb.Admin.NewsIssueView do
  use ChangelogWeb, :admin_view

  alias Changelog.NewsIssue
  alias ChangelogWeb.NewsItemView

  def ad_count(issue), do: NewsIssue.ad_count(issue)
  def item_count(issue), do: NewsIssue.item_count(issue)

  def show_or_preview(issue) do
    if NewsIssue.is_published(issue) do
      :show
    else
      :preview
    end
  end
end
