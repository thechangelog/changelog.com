defmodule ChangelogWeb.Admin.NewsItemCommentView do
  use ChangelogWeb, :admin_view

  alias Changelog.NewsItem
  alias ChangelogWeb.{NewsItemCommentView, PersonView}

  def permalink(conn, comment) do
    Routes.news_item_path(conn, :show, NewsItem.slug(comment.news_item)) <>
      NewsItemCommentView.permalink_path(comment)
  end
end
