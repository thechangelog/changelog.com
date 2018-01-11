defmodule ChangelogWeb.NewsAdView do
  use ChangelogWeb, :public_view

  alias Changelog.{Files, Hashid}
  alias ChangelogWeb.SponsorView

  def image_url(ad, version) do
    Files.Image.url({ad.image, ad}, version)
    |> String.replace_leading("/priv", "")
  end

  def slug(ad) do
    ad.headline
    |> String.downcase
    |> String.replace(~r/[^a-z0-9\s]/, "")
    |> String.replace(~r/\s+/, "-")
    |> Kernel.<>("-#{Hashid.encode(ad.id)}")
  end
end
