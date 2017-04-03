defmodule Changelog.PageView do
  use Changelog.Web, :public_view

  alias Changelog.{EpisodeView, NewsletterView, Podcast, PodcastView, SharedView, SponsorView, TimeView}

  def skype_account(podcast) do
    case podcast.slug do
      "podcast" -> "changelog-2"
      "gotime"  -> "changelog-4"
      "rfc"     -> "changelog-3"
      "jsparty" -> "changelog-3"
    end
  end
end
