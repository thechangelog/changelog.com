defmodule Changelog.LiveController do
  use Changelog.Web, :controller

  alias Changelog.{Episode, TimeView}

  def index(conn, _params) do
    live_window_start = TimeView.hours_ago(3)
    live_window_end = TimeView.hours_from_now(12)

    episodes =
      Episode.recorded_live
      |> Episode.recorded_future_to(live_window_start)
      |> Episode.newest_last(:recorded_at)
      |> Repo.all
      |> Episode.preload_all

    up_next = List.first(episodes)

    if up_next && up_next.recorded_at < live_window_end do
      render(conn, :live, episode: up_next, podcast: up_next.podcast)
    else
      render(conn, :upcoming, episodes: episodes)
    end
  end
end
