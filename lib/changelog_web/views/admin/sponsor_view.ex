defmodule ChangelogWeb.Admin.SponsorView do
  use ChangelogWeb, :admin_view

  alias Changelog.Sponsor
  alias ChangelogWeb.{Admin, EpisodeView, PersonView, SponsorView, TimeView}

  def avatar_url(sponsor, version), do: SponsorView.avatar_url(sponsor, version)

  def list_of_links(sponsor) do
    [
      %{
        value: sponsor.twitter_handle,
        icon: "twitter",
        url: SharedHelpers.twitter_url(sponsor.twitter_handle)
      },
      %{
        value: sponsor.github_handle,
        icon: "github",
        url: SharedHelpers.github_url(sponsor.github_handle)
      },
      %{value: sponsor.website, icon: "share", url: sponsor.website}
    ]
    |> Enum.reject(fn x -> x.value == nil end)
    |> Enum.map(fn x ->
      ~s{<a href="#{x.url}" class="ui icon button" target="_blank"><i class="#{x.icon} icon"></i></a>}
    end)
    |> Enum.join("")
  end

  def logo_url(sponsor, type, version), do: SponsorView.logo_url(sponsor, type, version)

  def sponsorship_count(sponsor, type), do: Sponsor.sponsorship_count(sponsor, type)
end
