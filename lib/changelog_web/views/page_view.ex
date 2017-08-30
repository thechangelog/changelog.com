defmodule ChangelogWeb.PageView do
  use ChangelogWeb, :public_view

  alias Changelog.Podcast
  alias ChangelogWeb.{EpisodeView, NewsletterView, PodcastView, SharedView,
                      SponsorView, TimeView}

  def skype_account(podcast) do
    case podcast.slug do
      "podcast" -> "changelog-2"
      "gotime"  -> "changelog-4"
      "rfc"     -> "changelog-3"
      "jsparty" -> "changelog-3"
    end
  end
end
