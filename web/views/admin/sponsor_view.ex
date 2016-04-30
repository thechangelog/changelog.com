defmodule Changelog.Admin.SponsorView do
  use Changelog.Web, :view

  alias Changelog.SponsorView

  import Scrivener.HTML

  def logo_image_url(sponsor, version), do: SponsorView.logo_image_url(sponsor, version)
end
