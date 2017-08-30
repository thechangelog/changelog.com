defmodule ChangelogWeb.Admin.SponsorView do
  use ChangelogWeb, :admin_view

  alias Changelog.Sponsor
  alias ChangelogWeb.SponsorView

  def logo_url(sponsor, type, version), do: SponsorView.logo_url(sponsor, type, version)

  def sponsorship_count(sponsor) do
    Sponsor.sponsorship_count(sponsor)
  end
end
