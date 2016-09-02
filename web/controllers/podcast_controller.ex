defmodule Changelog.PodcastController do
  use Changelog.Web, :controller

  alias Changelog.{Podcast, Episode}

  def index(conn, _params) do
    render(conn, :index, master: Podcast.master)
  end

  def show(conn, %{"slug" => slug}) do
    podcast =
      Podcast.public
      |> Repo.get_by!(slug: slug)
      |> Podcast.preload_hosts

    episodes =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Episode.newest_first
      |> Episode.limit(5)
      |> Repo.all
      |> Episode.preload_podcast
      |> Episode.preload_guests

    render(conn, :show, podcast: podcast, episodes: episodes)
  end

  def archive(conn, %{"slug" => slug}) do
    podcast = Repo.get_by!(Podcast, slug: slug)

    episodes =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_podcast
      |> Episode.preload_guests

    render(conn, :archive, podcast: podcast, episodes: episodes)
  end

  def feed(conn, %{"slug" => slug}) do
    podcast = Repo.get_by!(Podcast, slug: slug)

    episodes =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_all

    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("feed.xml", podcast: podcast, episodes: episodes)
  end

  def master(conn, _params) do
    episodes =
      Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_all

    render(conn, :master, podcast: Podcast.master, episodes: episodes)
  end

  def master_feed(conn, _params) do
    episodes =
      Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_all

    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("master.xml", podcast: Podcast.master, episodes: episodes)
  end
end
