defmodule ChangelogWeb.PageView do
  use ChangelogWeb, :public_view

  alias Changelog.{NewsSponsorship, Person, Repo}
  alias ChangelogWeb.{EpisodeView, NewsletterView, TimeView}

  def members_count, do: Repo.count(Person.joined())

  def skype_account(podcast) do
    case podcast.slug do
      "gotime"  -> "changelog-4"
      "jsparty" -> "changelog-4"
      _else     -> "changelog-2"
    end
  end

  def uses_skype?(podcast) do
    case podcast.slug do
      "afk" -> false
      _else -> true
    end
  end
end
