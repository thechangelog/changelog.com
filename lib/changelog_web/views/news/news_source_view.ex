defmodule ChangelogWeb.NewsSourceView do
  use ChangelogWeb, :public_view

  alias Changelog.Files.Icon
  alias Changelog.NewsItem
  alias ChangelogWeb.NewsItemView

  def icon_url(news_source), do: icon_url(news_source, :small)
  def icon_url(news_source, version) do
    Icon.url({news_source.icon, news_source}, version)
    |> String.replace_leading("/priv", "")
  end
end
