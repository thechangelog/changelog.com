defmodule ChangelogWeb.Admin.PageController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, NewsItem, Newsletters, Person, Podcast}

  plug Authorize, Policies.Admin

  def index(conn = %{assigns: %{current_user: me = %{admin: true}}}, _params) do
    newsletters =
      [Newsletters.weekly(),
       Newsletters.nightly(),
       Newsletters.gotime(),
       Newsletters.jsparty(),
       Newsletters.practicalai()]
      |> Enum.map(&Newsletters.get_stats/1)

    render(conn, :index,
      newsletters: newsletters,
      draft_episodes: draft_episodes(),
      draft_items: draft_items(me),
      members: members(),
      podcasts: podcasts())
  end
  def index(conn = %{assigns: %{current_user: %{editor: true}}}, _params) do
    redirect(conn, to: admin_news_item_path(conn, :index))
  end
  def index(conn = %{assigns: %{current_user: %{host: true}}}, _params) do
    redirect(conn, to: admin_podcast_path(conn, :index))
  end

  defp draft_episodes do
    Episode.unpublished
    |> Episode.newest_last(:recorded_at)
    |> Episode.distinct_podcast
    |> Repo.all
    |> Episode.preload_podcast
  end

  defp draft_items(user) do
    NewsItem.drafted
    |> NewsItem.newest_first(:inserted_at)
    |> NewsItem.logged_by(user)
    |> NewsItem.preload_all
    |> Repo.all
  end

  defp members do
    %{today: Repo.count(Person.joined_today()),
      slack: Repo.count(Person.in_slack()),
      total: Repo.count(Person.joined())}
  end

  defp podcasts do
    Podcast.active
    |> Podcast.by_position
    |> Podcast.preload_hosts
    |> Repo.all
  end
end
