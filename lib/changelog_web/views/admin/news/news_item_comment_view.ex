defmodule ChangelogWeb.Admin.NewsItemCommentView do
  use ChangelogWeb, :admin_view

  alias ChangelogWeb.{NewsItemView, NewsItemCommentView, PersonView}

  def permalink(conn, comment) do
    news_item_path(conn, :show, NewsItemView.slug(comment.news_item)) <> NewsItemCommentView.permalink_path(comment)
  end
end
