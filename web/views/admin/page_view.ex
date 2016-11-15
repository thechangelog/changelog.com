defmodule Changelog.Admin.PageView do
  use Changelog.Web, :view

  alias Changelog.{Episode, Repo, TimewView}
  alias Changelog.Admin.{NewsletterView, EpisodeView, PodcastView}

  def recent_episodes(podcast, limit \\ 5) do
    podcast
    |> Ecto.assoc(:episodes)
    |> Episode.published
    |> Episode.newest_first
    |> Episode.limit(limit)
    |> Repo.all
  end
end
