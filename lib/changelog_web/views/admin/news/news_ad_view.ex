defmodule ChangelogWeb.Admin.NewsAdView do
  use ChangelogWeb, :admin_view

  alias Changelog.{Files}

  def image_url(news_ad, version) do
    Files.Image.url({news_ad.image, news_ad}, version)
    |> String.replace_leading("/priv", "")
  end
end
