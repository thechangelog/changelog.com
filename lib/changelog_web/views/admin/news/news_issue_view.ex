defmodule ChangelogWeb.Admin.NewsIssueView do
  use ChangelogWeb, :admin_view

  alias Changelog.NewsIssue
  alias ChangelogWeb.Admin.NewsItemView

  def ad_count(news_issue), do: NewsIssue.ad_count(news_issue)
  def item_count(news_issue), do: NewsIssue.item_count(news_issue)

  def show_or_preview(news_issue) do
    if NewsIssue.is_published(news_issue) do
      :show
    else
      :preview
    end
  end
end
