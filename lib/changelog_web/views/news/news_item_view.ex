defmodule ChangelogWeb.NewsItemView do
  use ChangelogWeb, :public_view

  alias Changelog.{Files, NewsAd, NewsItem}

  def image_url(item, version) do
    Files.Image.url({item.image, item}, version)
    |> String.replace_leading("/priv", "")
  end

  def render_item_or_ad(item = %NewsItem{}), do: render("_item.html", item: item)
  def render_item_or_ad(ad = %NewsAd{}), do: render("_ad.html", ad: ad)
end
