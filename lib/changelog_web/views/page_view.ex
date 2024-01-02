defmodule ChangelogWeb.PageView do
  use ChangelogWeb, :public_view

  alias Changelog.{Person, Podcast, Repo, Sponsor, StringKit}
  alias ChangelogWeb.{EpisodeView, SponsorView, TimeView}

  def members_count, do: Repo.count(Person.joined())

  def sponsor_avatar_url(story) do
    sponsor = Repo.get_by(Sponsor, name: story.sponsor) || %{avatar: nil}
    SponsorView.avatar_url(sponsor, :small)
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
