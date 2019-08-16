defmodule ChangelogWeb.Admin.SponsorView do
  use ChangelogWeb, :admin_view

  alias Changelog.Sponsor
  alias ChangelogWeb.{Admin, EpisodeView, SponsorView, TimeView}

  def avatar_url(sponsor, version), do: SponsorView.avatar_url(sponsor, version)
  def logo_url(sponsor, type, version), do: SponsorView.logo_url(sponsor, type, version)

  def sponsorship_count(sponsor, type), do: Sponsor.sponsorship_count(sponsor, type)
end
