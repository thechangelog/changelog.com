defmodule ChangelogWeb.PageView do
  use ChangelogWeb, :public_view

  alias Changelog.{Person, Podcast, Repo, Sponsor}
  alias ChangelogWeb.{EpisodeView, PersonView, SponsorView, TimeView}

  def members_count, do: Repo.count(Person.joined())

  def sponsor_avatar_url(story) do
    sponsor = Repo.get_by(Sponsor, name: story.sponsor) || %{avatar: nil}
    SponsorView.avatar_url(sponsor, :small)
  end
end
