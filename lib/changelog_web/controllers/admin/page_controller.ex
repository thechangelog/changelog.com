defmodule ChangelogWeb.Admin.PageController do
  use ChangelogWeb, :controller

  alias Changelog.{Cache, Episode, EpisodeRequest, EpisodeStat, NewsItem, Newsletters, Person}

  plug Authorize, Policies.Admin

  def index(conn = %{assigns: %{current_user: me = %{admin: true}}}, _params) do
    newsletters =
      Newsletters.all()
      |> Enum.map(&Newsletters.get_stats/1)

    conn
    |> assign(:newsletters, newsletters)
    |> assign(:episode_drafts, episode_drafts())
    |> assign(:episode_requests, episode_requests())
    |> assign(:item_drafts, item_drafts(me))
    |> assign(:members, members())
    |> assign(:podcasts, Cache.podcasts())
    |> assign(:reach, reach())
    |> render(:index)
  end
  def index(conn = %{assigns: %{current_user: %{host: true}}}, _params) do
    redirect(conn, to: Routes.admin_podcast_path(conn, :index))
  end
  def index(conn = %{assigns: %{current_user: %{editor: true}}}, _params) do
    redirect(conn, to: Routes.admin_news_item_path(conn, :index))
  end

  def purge(conn, _params) do
    Cache.delete_all()

    conn
    |> put_flash(:result, "success")
    |> redirect(to: Routes.admin_page_path(conn, :index))
  end

  defp episode_drafts do
    Episode.unpublished()
    |> Episode.newest_last(:recorded_at)
    |> Episode.distinct_podcast()
    |> Episode.preload_podcast()
    |> Repo.all()
  end

  defp episode_requests do
    EpisodeRequest.fresh()
    |> EpisodeRequest.sans_episode()
    |> EpisodeRequest.newest_first()
    |> EpisodeRequest.preload_all()
    |> Repo.all()
  end

  defp item_drafts(user) do
    NewsItem.drafted()
    |> NewsItem.newest_first(:inserted_at)
    |> NewsItem.logged_by(user)
    |> NewsItem.preload_all()
    |> Repo.all()
  end

  defp members do
    %{today: Repo.count(Person.joined_today()),
      slack: Repo.count(Person.in_slack()),
      total: Repo.count(Person.joined())}
  end

  defp reach do
    now = Timex.today() |> Timex.shift(days: -1)
    then = now |> Timex.shift(years: -1)

    Cache.get_or_store("stats-reach-#{now}", fn ->
      %{as_of: Timex.now(),
        now_7:   EpisodeStat.date_range_reach(now, days: -7),
        now_30:  EpisodeStat.date_range_reach(now, days: -30),
        now_90:  EpisodeStat.date_range_reach(now, days: -90),
        prev_7:  EpisodeStat.date_range_reach(Timex.shift(now, days: -7), days: -7),
        prev_30: EpisodeStat.date_range_reach(Timex.shift(now, days: -30), days: -30),
        prev_90: EpisodeStat.date_range_reach(Timex.shift(now, days: -90), days: -90),
        then_7:  EpisodeStat.date_range_reach(then, days: -7),
        then_30: EpisodeStat.date_range_reach(then, days: -30),
        then_90: EpisodeStat.date_range_reach(then, days: -90)}
    end)
  end
end
