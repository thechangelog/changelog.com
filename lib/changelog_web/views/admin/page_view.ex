defmodule ChangelogWeb.Admin.PageView do
  use ChangelogWeb, :admin_view

  alias Changelog.{Episode, Repo}
  alias ChangelogWeb.TimeView
  alias ChangelogWeb.Admin.{EpisodeView, NewsItemView, NewsletterView,}

  def recent_episodes(podcast, limit \\ 5) do
    podcast
    |> Ecto.assoc(:episodes)
    |> Episode.published
    |> Episode.newest_first
    |> Episode.limit(limit)
    |> Repo.all
  end
end
