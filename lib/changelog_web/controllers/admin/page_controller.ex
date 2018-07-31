defmodule ChangelogWeb.Admin.PageController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, Newsletters, Person, Podcast, Post}

  plug Authorize, Changelog.AdminPolicy

  def index(conn = %{assigns: %{current_user: %{admin: true}}}, _params) do
    newsletters =
      [Newsletters.community(),
       Newsletters.weekly(),
       Newsletters.nightly(),
       Newsletters.gotime(),
       Newsletters.jsparty(),
       Newsletters.practicalai()]
      |> Enum.map(&Newsletters.get_stats/1)

    render(conn, :index,
      newsletters: newsletters,
      draft_episodes: draft_episodes(),
      draft_posts: draft_posts(),
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

  defp draft_posts do
    Post.unpublished
    |> Post.newest_last(:inserted_at)
    |> Repo.all
    |> Post.preload_author
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
