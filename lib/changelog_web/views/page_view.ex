defmodule ChangelogWeb.PageView do
  use ChangelogWeb, :public_view

  alias Changelog.NewsSponsorship
  alias ChangelogWeb.{EpisodeView, NewsletterView, TimeView}

  def skype_account(podcast) do
    case podcast.slug do
      "gotime"  -> "changelog-4"
      "jsparty" -> "changelog-3"
      _else     -> "changelog-2"
    end
  end
end
