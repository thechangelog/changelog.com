defmodule ChangelogWeb.Admin.NewsItemView do
  use ChangelogWeb, :admin_view

  alias Changelog.{NewsItem, NewsSource, Person, Topic}
  alias ChangelogWeb.{Endpoint, PersonView, NewsItemView}
  alias ChangelogWeb.Admin.NewsSponsorshipView

  def image_url(item, version), do: NewsItemView.image_url(item, version)

  def is_edited(item), do: item.inserted_at < item.updated_at

  def bookmarklet_code do
    url = admin_news_item_url(Endpoint, :new, quick: true, url: "")
    ~s/javascript:(function() {window.open('#{url}'+location.href);})();/
  end

  def show_or_preview_path(conn, item) do
    if NewsItem.is_published(item) do
      news_item_path(conn, :show, NewsItem.slug(item))
    else
      news_item_path(conn, :preview, item)
    end
  end

  def type_options do
    NewsItem.Type.__enum_map__()
    |> Enum.map(fn({k, _v}) -> {String.capitalize(Atom.to_string(k)), k} end)
  end
end
