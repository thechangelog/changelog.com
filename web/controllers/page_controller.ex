defmodule Changelog.PageController do
  use Changelog.Web, :controller

  alias Changelog.{Episode, Newsletter}

  # pages that need special treatment get their own matched function
  # all others simply render the template of the same name
  def action(conn, params) do
    case action_name(conn) do
      :home           -> home(conn, params)
      :sponsorship    -> sponsorship(conn, params)
      :weekly_archive -> weekly_archive(conn, params)
      name            -> render(conn, name)
    end
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

  def sponsorship(conn, _params) do
    weekly = Newsletter.weekly() |> Newsletter.get_stats

    render(conn, :sponsorship, weekly: weekly)
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
