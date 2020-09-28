defmodule ChangelogWeb.Admin.PageController do
  use ChangelogWeb, :controller

  alias Changelog.{
    Cache,
    Episode,
    EpisodeRequest,
    EpisodeStat,
    NewsItem,
    Newsletters,
    Person,
    Podcast
  }

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

  def reach(conn, params) do
    podcast = Repo.get_by(Podcast, slug: Map.get(params, "podcast", "nope"))
    range = params |> Map.get("range", "now_7") |> String.to_existing_atom()
    dates = EpisodeStat.reach_dates(range)
    minimum = Map.get(params, "min", "10") |> String.to_integer()

    episodes = if podcast do
      EpisodeStat.date_range_episode_reach(podcast, dates, minimum)
    else
      EpisodeStat.date_range_episode_reach(dates, minimum)
    end |> Enum.map(fn(stat) ->
      Episode
      |> Repo.get(stat.episode_id)
      |> Episode.preload_podcast()
      |> Map.put(:focused_reach, stat.reach)
    end)

    conn
    |> assign(:podcast, podcast)
    |> assign(:dates, dates)
    |> assign(:episodes, episodes)
    |> render(:reach)
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
    %{
      today: Repo.count(Person.joined_today()),
      slack: Repo.count(Person.in_slack()),
      total: Repo.count(Person.joined())
    }
  end

  def reach do
    now = Timex.today() |> Timex.shift(days: -1)

    Cache.get_or_store("stats-reach-#{now}", fn ->
      %{
        as_of: Timex.now(),
        now_7: EpisodeStat.date_range_reach(:now_7),
        now_30: EpisodeStat.date_range_reach(:now_30),
        now_90: EpisodeStat.date_range_reach(:now_90),
        now_year: EpisodeStat.date_range_reach(:now_year),
        prev_7: EpisodeStat.date_range_reach(:prev_7),
        prev_30: EpisodeStat.date_range_reach(:prev_30),
        prev_90: EpisodeStat.date_range_reach(:prev_90),
        prev_year: EpisodeStat.date_range_reach(:prev_year),
        then_7: EpisodeStat.date_range_reach(:then_7),
        then_30: EpisodeStat.date_range_reach(:then_30),
        then_90: EpisodeStat.date_range_reach(:then_90)
      }
    end)
  end
end
