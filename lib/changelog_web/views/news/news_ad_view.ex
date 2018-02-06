defmodule ChangelogWeb.NewsAdView do
  use ChangelogWeb, :public_view

  alias Changelog.{Files, Hashid}
  alias ChangelogWeb.{Endpoint, SponsorView}

  def image_path(ad, version) do
    {ad.image, ad}
    |> Files.Image.url(version)
    |> String.replace_leading("/priv", "")
  end

  def image_url(ad, version) do
    static_url(Endpoint, image_path(ad, version))
  end

  def slug(ad) do
    ad.headline
    |> String.downcase
    |> String.replace(~r/[^a-z0-9\s]/, "")
    |> String.replace(~r/\s+/, "-")
    |> Kernel.<>("-#{hashid(ad)}")
  end

  def hashid(ad) do
    Hashid.encode(ad.id)
  end
end
