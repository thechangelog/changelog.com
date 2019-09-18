defmodule ChangelogWeb.LiveController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, Hashid, Icecast}
  alias ChangelogWeb.TimeView

  def index(conn, _params) do
    episodes =
      Episode.recorded_live()
      |> Episode.recorded_future_to(TimeView.hours_ago(2))
      |> Episode.newest_last(:recorded_at)
      |> Repo.all()
      |> Episode.preload_all()

    conn
    |> assign(:episodes, episodes)
    |> render(:index)
  end

  def show(conn, %{"id" => hashid}) do
    episode =
      Episode.recorded_live()
      |> Repo.get_by!(id: Hashid.decode(hashid))
      |> Episode.preload_all()

    conn
    |> assign(:episode, episode)
    |> assign(:podcast, episode.podcast)
    |> render(:show)
  end

  def status(conn, _params) do
    json(conn, Icecast.get_stats())
  end
end
