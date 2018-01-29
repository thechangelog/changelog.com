defmodule ChangelogWeb.NewsSourceView do
  use ChangelogWeb, :public_view

  alias Changelog.Files.Icon
  alias Changelog.NewsSource
  alias ChangelogWeb.NewsItemView

  def admin_edit_link(conn, user, source) do
    if user && user.admin do
      link("[Edit]", to: admin_news_source_path(conn, :edit, source, next: current_path(conn)), data: [turbolinks: false])
    end
  end

  def icon_url(news_source), do: icon_url(news_source, :small)
  def icon_url(news_source, version) do
    if (news_source.icon) do
      Icon.url({news_source.icon, news_source}, version)
      |> String.replace_leading("/priv", "")
    else
      "/images/icons/type-topic.svg"
    end
  end

  def news_count(topic), do: NewsSource.news_count(topic)
end
