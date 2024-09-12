defmodule ChangelogWeb.SponsorView do
  use ChangelogWeb, :public_view

  alias Changelog.Files.{Avatar, ColorLogo, DarkLogo, LightLogo}
  alias Changelog.StringKit
  alias ChangelogWeb.EpisodeView

  def avatar_url(sponsor), do: avatar_url(sponsor, :small)

  def avatar_url(sponsor, version) do
    Avatar.url({sponsor.avatar, sponsor}, version)
  end

  def total_reach(sponsorships) do
    sponsorships
    |> Enum.map(& &1.episode.download_count)
    |> Enum.sum()
    |> SharedHelpers.pretty_downloads()
  end

  def list_of_links(sponsor, separator \\ ", ") do
    [
      %{
        value: sponsor.twitter_handle,
        text: "Twitter",
        url: SharedHelpers.twitter_url(sponsor.twitter_handle)
      },
      %{
        value: sponsor.github_handle,
        text: "GitHub",
        url: SharedHelpers.github_url(sponsor.github_handle)
      },
      %{value: sponsor.website, text: "Website", url: sponsor.website}
    ]
    |> Enum.reject(fn x -> x.value == nil end)
    |> Enum.map(fn x -> ~s{<a href="#{x.url}" rel="external ugc">#{x.text}</a>} end)
    |> Enum.join(separator)
  end

  def logo_url(sponsor, type, version) do
    {module, file} =
      case type do
        :color_logo -> {ColorLogo, sponsor.color_logo}
        :dark_logo -> {DarkLogo, sponsor.dark_logo}
        :light_logo -> {LightLogo, sponsor.light_logo}
      end

    module.url({file, sponsor}, version)
  end

  def sponsorship_data(sponsorships) do
    sponsorships
    |> Enum.map(fn %{episode: episode} ->
      [
        TimeView.terse_date(episode.published_at),
        EpisodeView.podcast_name_and_number(episode),
        SharedHelpers.pretty_downloads(episode)
      ] |> Enum.join(" - ")
    end)
    |> Enum.join("\n")
  end

  def sponsors_list do
    [
      {"Toptal", "https://www.toptal.com/?utm_source=changelog"},
      {"Fastly", "http://fastly.com/?utm_source=changelog"},
      {"Linode", "https://www.linode.com/changelog"},
      {"Rollbar", "https://rollbar.com/changelog"},
      {"IBM", "http://www.ibm.com/?utm_source=changelog"},
      {"StrongLoop", "https://strongloop.com/?utm_source=changelog"},
      {"Flatiron", "http://flatiron500.com"},
      {"Codeschool", "https://www.codeschool.com/changelog"},
      {"Digital Ocean", "https://m.do.co/c/313e6c84edc3"},
      {"GoCD", "https://www.gocd.io/changelog"},
      {"Heap", "https://heapanalytics.com/?utm_source=changelog"},
      {"Sentry", "https://sentry.io/?utm_source=changelog"},
      {"Node.js", "https://nodejs.org/?utm_source=changelog"},
      {"Linux Foundation", "https://www.linuxfoundation.org/?utm_source=changelog"},
      {"ATO", "https://allthingsopen.org/?utm_source=changelog"},
      {"O'Reilly Media", "http://www.oreilly.com/pub/cpc/58768"},
      {"ElixirConf", "https://elixirconf.com/?utm_source=changelog"},
      {"Compose", "https://compose.com/changelog"},
      {"Hired", "https://hired.com/changelog"},
      {"Datadog", "https://www.datadoghq.com/?utm_source=changelog"},
      {"Casper", "https://casper.com/changelog"},
      {"Imgix", "https://www.imgix.com/?utm_source=changelog"},
      {"Hacker Paradise", "http://www.hackerparadise.org/"},
      {"Codeship", "https://codeship.com/changelog"}
    ]
  end
end
