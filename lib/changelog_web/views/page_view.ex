defmodule ChangelogWeb.PageView do
  use ChangelogWeb, :public_view

  alias Changelog.{NewsSponsorship, Repo, Sponsor}
  alias ChangelogWeb.{EpisodeView, NewsItemView, NewsletterView, SponsorView, TimeView}

  def uses_skype?(podcast) do
    case podcast.slug do
      "afk" -> false
      _else          -> true
    end
  end

  def skype_account(podcast) do
    case podcast.slug do
      "gotime"  -> "changelog-4"
      "jsparty" -> "changelog-3"
      _else     -> "changelog-2"
    end
  end

  def sponsor_avatar_url(story) do
    sponsor = Repo.get_by(Sponsor, name: story.sponsor) || %{avatar: nil}
    SponsorView.avatar_url(sponsor, :small)
  end
end
