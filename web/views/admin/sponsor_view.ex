defmodule Changelog.Admin.SponsorView do
  use Changelog.Web, :view

  import Changelog.Admin.SharedView
  import Scrivener.HTML

  alias Changelog.SponsorView

  def logo_image_url(sponsor, version), do: SponsorView.logo_image_url(sponsor, version)
end
