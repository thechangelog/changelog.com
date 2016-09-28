defmodule Changelog.PageController do
  use Changelog.Web, :controller

  alias Changelog.{Episode, Post}
  alias Ecto.DateTime

  # pages that need special treatment get their own matched function
  # all others simply render the template of the same name
  def action(conn, params) do
    case action_name(conn) do
      :feed           -> feed(conn, params)
      :home           -> home(conn, params)
      :weekly_archive -> weekly_archive(conn, params)
      action          -> render(conn, action)
    end
  end

  def feed(conn, _params) do
    episodes =
      Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_podcast

    posts =
      Post.published
      |> Post.newest_first
      |> Repo.all
      |> Post.preload_author

    items = (episodes ++ posts)
      |> Enum.sort(&(DateTime.to_erl(&1.published_at) > DateTime.to_erl(&2.published_at)))

    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("feed.xml", items: items)
  end

  def home(conn, _params) do
    featured =
      Episode.published
      |> Episode.featured
      |> Episode.newest_first
      |> Episode.limit(1)
      |> Repo.all
      |> Episode.preload_podcast
      |> Episode.preload_sponsors

    render(conn, :home, featured: featured)
  end

  def weekly_archive(conn, _params) do
    issues =
      ConCache.get_or_store(:app_cache, "weekly_archive", fn() ->
        campaigns =
          Craisin.Client.campaigns("e8870c50d493e5cc72c78ffec0c5b86f")
          |> Enum.filter(fn(c) -> String.match?(c["Name"], ~r/\AWeekly - Issue \#\d+\z/) end)

        %ConCache.Item{value: campaigns, ttl: :timer.hours(24)}
      end)

    render(conn, :weekly_archive, issues: issues)
  end
end
