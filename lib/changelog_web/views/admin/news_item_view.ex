defmodule ChangelogWeb.Admin.NewsItemView do
  use ChangelogWeb, :admin_view

  alias Changelog.{Files, NewsItem, NewsSource, Person, Sponsor, Topic}
  alias ChangelogWeb.{Endpoint, PersonView}

  def bookmarklet_code do
    url = admin_news_item_url(Endpoint, :new, quick: true, url: "")
    ~s/javascript:(function() {window.open('#{url}'+location.href);})();/
  end

  def image_url(news_item, version) do
    Files.Image.url({news_item.image, news_item}, version)
    |> String.replace_leading("/priv", "")
  end

  def type_options do
    NewsItem.Type.__enum_map__()
    |> Enum.map(fn({k, _v}) -> {String.capitalize(Atom.to_string(k)), k} end)
  end
end
