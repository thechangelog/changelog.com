defmodule ChangelogWeb.LiveController do
  use ChangelogWeb, :controller

  alias Changelog.Episode
  alias ChangelogWeb.TimeView
  alias ChangelogWeb.Plug.ResponseCache

  plug ResponseCache

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
      |> Repo.get_by!(id: Episode.decode(hashid))
      |> Episode.preload_all()

    conn
    |> assign(:episode, episode)
    |> assign(:podcast, episode.podcast)
    |> render(:show)
  end

  def ical(conn, params) do
    episodes =
      Episode.with_podcast_slug(params["slug"])
      |> Episode.recorded_live()
      |> Episode.recorded_future_to(TimeView.hours_ago(2))
      |> Episode.newest_last(:recorded_at)
      |> Repo.all()
      |> Episode.preload_all()

    conn
    |> assign(:episodes, episodes)
    |> ResponseCache.cache_public(:timer.minutes(5))
    |> render("ical.ics")
  end

  def status(conn, _params), do: json(conn, %{streaming: false, listeners: 0})
end
