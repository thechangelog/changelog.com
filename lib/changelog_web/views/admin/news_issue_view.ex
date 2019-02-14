defmodule ChangelogWeb.Admin.NewsIssueView do
  use ChangelogWeb, :admin_view

  alias Changelog.{NewsIssue, NewsItem}
  alias ChangelogWeb.NewsItemView

  def ad_count(issue), do: NewsIssue.ad_count(issue)
  def item_count(issue), do: NewsIssue.item_count(issue)

  def item_icon(item) do
    icon_class = cond do
      item.image -> "image"
      NewsItem.is_audio(item) -> "volume up"
      NewsItem.is_video(item) -> "film"
      true -> nil
    end

    if icon_class, do: content_tag(:i, "", class: "#{icon_class} icon")
  end

  def show_or_preview(issue) do
    if NewsIssue.is_published(issue) do
      :show
    else
      :preview
    end
  end
end
