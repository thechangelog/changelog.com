defmodule Changelog.PodcastController do
  use Changelog.Web, :controller

  alias Changelog.{Podcast, Episode}

  def index(conn, _params) do
    render(conn, :index)
  end

  def show(conn, %{"slug" => slug}) do
    podcast = get_podcast(slug)

    episodes =
      podcast_episodes(podcast)
      |> Episode.published
      |> Episode.newest_first
      |> Episode.limit(5)
      |> Repo.all
      |> Episode.preload_podcast
      |> Episode.preload_guests

    render(conn, :show, podcast: podcast, episodes: episodes)
  end

  def archive(conn, %{"slug" => slug}) do
    podcast = get_podcast(slug)

    episodes =
      podcast_episodes(podcast)
      |> Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_podcast
      |> Episode.preload_guests

    render(conn, :archive, podcast: podcast, episodes: episodes)
  end

  def feed(conn, %{"slug" => slug}) do
    podcast = get_podcast(slug)

    episodes =
      podcast_episodes(podcast)
      |> Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_all

    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("feed.xml", podcast: podcast, episodes: episodes)
  end

  defp get_podcast(slug) do
    if slug == "master" do
      Podcast.master
    else
      Podcast.public
      |> Repo.get_by!(slug: slug)
      |> Podcast.preload_hosts
    end
  end

  defp podcast_episodes(podcast) do
    if Podcast.is_master(podcast) do
      from(e in Episode)
    else
      assoc(podcast, :episodes)
    end
  end
end
