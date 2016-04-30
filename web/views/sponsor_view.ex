defmodule Changelog.SponsorView do
  use Changelog.Web, :view

  def logo_image_url(sponsor, version) do
    Changelog.LogoImage.url({sponsor.logo_image, sponsor}, version)
    |> String.replace_leading("priv/static", "/")
  end
end
