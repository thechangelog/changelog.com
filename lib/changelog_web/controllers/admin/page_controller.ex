defmodule ChangelogWeb.Admin.PageController do
  use ChangelogWeb, :controller

  alias Changelog.{Cache, Episode, EpisodeStat, NewsItem, Newsletters, Person}

  plug Authorize, Policies.Admin

  def index(conn = %{assigns: %{current_user: me = %{admin: true}}}, _params) do
    newsletters =
      Newsletters.all()
      |> Enum.map(&Newsletters.get_stats/1)

    conn
    |> assign(:newsletters, newsletters)
    |> assign(:draft_episodes, draft_episodes())
    |> assign(:draft_items, draft_items(me))
    |> assign(:members, members())
    |> assign(:podcasts, Cache.podcasts())
    |> assign(:reach, reach())
    |> render(:index)
  end
  def index(conn = %{assigns: %{current_user: %{editor: true}}}, _params) do
    redirect(conn, to: admin_news_item_path(conn, :index))
  end
  def index(conn = %{assigns: %{current_user: %{host: true}}}, _params) do
    redirect(conn, to: admin_podcast_path(conn, :index))
  end

  defp draft_episodes do
    Episode.unpublished()
    |> Episode.newest_last(:recorded_at)
    |> Episode.distinct_podcast()
    |> Episode.preload_podcast()
    |> Repo.all()
  end

  defp draft_items(user) do
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
    yesterday = Timex.today() |> Timex.shift(days: -1)
    yesteryear = yesterday |> Timex.shift(years: -1)

    Cache.get_or_store("stats-reach-#{yesterday}", fn ->
      %{as_of: Timex.now(),
        now_seven: EpisodeStat.date_range_reach(yesterday, days: -7),
        now_thirty: EpisodeStat.date_range_reach(yesterday, days: -30),
        now_ninety: EpisodeStat.date_range_reach(yesterday, days: -90),
        then_seven: EpisodeStat.date_range_reach(yesteryear, days: -7),
        then_thirty: EpisodeStat.date_range_reach(yesteryear, days: -30),
        then_ninety: EpisodeStat.date_range_reach(yesteryear, days: -90)}
    end)
  end
end
