defmodule ChangelogWeb.NewsAdView do
  use ChangelogWeb, :public_view

  alias Changelog.{Files, Hashid}
  alias ChangelogWeb.{Endpoint, SponsorView}

  def hashid(ad), do: Hashid.encode(ad.id)

  def image_link(ad, version \\ :large) do
    if ad.image do
      content_tag :div, class: "news_item-image" do
        link to: ad.url do
          tag(:img, src: image_url(ad, version), alt: ad.headline)
        end
      end
    end
  end

  def image_path(ad, version) do
    {ad.image, ad}
    |> Files.Image.url(version)
    |> String.replace_leading("/priv", "")
  end

  def image_url(ad, version), do: static_url(Endpoint, image_path(ad, version))

  def slug(ad) do
    ad.headline
    |> String.downcase
    |> String.replace(~r/[^a-z0-9\s]/, "")
    |> String.replace(~r/\s+/, "-")
    |> Kernel.<>("-#{hashid(ad)}")
  end
end
