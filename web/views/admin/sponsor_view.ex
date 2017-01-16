defmodule Changelog.Admin.SponsorView do
  use Changelog.Web, :admin_view

  alias Changelog.SponsorView

  def logo_url(sponsor, type, version), do: SponsorView.logo_url(sponsor, type, version)

  def sponsorship_count(sponsor) do
    Changelog.Sponsor.sponsorship_count(sponsor)
  end
end
