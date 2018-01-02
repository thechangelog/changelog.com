defmodule ChangelogWeb.Admin.NewsAdView do
  use ChangelogWeb, :admin_view

  alias Changelog.{Files}

  def image_url(ad, version) do
    Files.Image.url({ad.image, ad}, version)
    |> String.replace_leading("/priv", "")
  end
end
