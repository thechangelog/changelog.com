defmodule ChangelogWeb.PageController do
  use ChangelogWeb, :controller

  alias Changelog.{Cache, Episode, Newsletters, NewsSponsorship, Podcast}
  alias ChangelogWeb.TimeView

  plug PublicEtsCache
  plug RequireGuest, "before joining" when action in [:join]

  # pages that need special treatment get their own matched function
  # all others simply render the template of the same name
  def action(conn, _) do
    case action_name(conn) do
      :guest           -> guest(conn, Map.get(conn.params, "slug"))
      :home            -> home(conn, conn.params)
      :sponsor         -> sponsor(conn, conn.params)
      :sponsor_pricing -> sponsor_pricing(conn, conn.params)
      :sponsor_story   -> sponsor_story(conn, Map.get(conn.params, "slug"))
      :weekly          -> weekly(conn, conn.params)
      :weekly_archive  -> weekly_archive(conn, conn.params)
      name             -> render(conn, name)
    end
  end

  def guest(conn, slug) when is_nil(slug), do: guest(conn, "podcast")
  def guest(conn, slug) do
    active =
      Podcast.active
      |> Podcast.oldest_first
      |> Repo.all

    podcast = Podcast.get_by_slug!(slug)
    episode =
      Podcast.get_episodes(podcast)
      |> Episode.published
      |> Episode.newest_first
      |> Episode.limit(1)
      |> Repo.one
      |> Episode.preload_podcast

    conn
    |> assign(:active, active)
    |> assign(:podcast, podcast)
    |> assign(:episode, episode)
    |> render(:guest)
    |> cache_public_response()
  end

  def home(conn, _params) do
    featured =
      Episode.published
      |> Episode.featured
      |> Episode.newest_first
      |> Episode.limit(5)
      |> Repo.all
      |> Episode.preload_podcast
      |> Episode.preload_sponsors

    render(conn, :home, featured: featured)
  end

  def sponsor(conn, _params) do
    weekly = Newsletters.weekly() |> Newsletters.get_stats()
    examples = Changelog.SponsorStory.examples()
    ads = NewsSponsorship.get_ads_for_index()
    render(conn, :sponsor, weekly: weekly, examples: examples, ads: ads)
  end

  def sponsor_pricing(conn, _params) do
    weekly = Newsletters.weekly() |> Newsletters.get_stats()
    weeks = Timex.today |> TimeView.closest_monday_to() |> TimeView.weeks(12)
    render(conn, :sponsor_pricing, weekly: weekly, weeks: weeks)
  end

  def sponsor_story(conn, slug) do
    story = Changelog.SponsorStory.get_by_slug(slug)
    render(conn, :sponsor_story, story: story)
  end

  def weekly(conn, _params) do
    render(conn, :weekly, latest: List.first(get_weekly_issues()))
  end

  def weekly_archive(conn, _params) do
    render(conn, :weekly_archive, issues: get_weekly_issues())
  end

  defp get_weekly_issues do
    Cache.get_or_store("weekly_archive", :timer.hours(24), fn ->
      Craisin.Client.campaigns("e8870c50d493e5cc72c78ffec0c5b86f")
      |> Enum.filter(fn(c) -> String.match?(c["Name"], ~r/\AWeekly - Issue \#\d+\z/) end)
    end)
  end
end
