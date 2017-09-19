defmodule ChangelogWeb.Admin.NewsSourceView do
  use ChangelogWeb, :admin_view

  alias ChangelogWeb.NewsSourceView

  def icon_url(news_source), do: NewsSourceView.icon_url(news_source)
end
