defmodule Changelog.EpisodeController do
  use Changelog.Web, :controller

  alias Changelog.{Podcast, Episode}

  plug Changelog.Plug.RequireAdmin, "before preview" when action in [:preview]

  def show(conn, %{"podcast" => podcast, "slug" => slug}) do
    podcast = Repo.get_by!(Podcast, slug: podcast)

    episode =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Repo.get_by!(slug: slug)
      |> Repo.preload(:podcast)
      |> Episode.preload_guests
      |> Episode.preload_sponsors

    render conn, :show, podcast: podcast, episode: episode
  end

  def preview(conn, %{"podcast" => podcast, "slug" => slug}) do
    podcast = Repo.get_by!(Podcast, slug: podcast)

    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)
      |> Repo.preload(:podcast)
      |> Episode.preload_guests
      |> Episode.preload_sponsors

    render conn, :show, podcast: podcast, episode: episode
  end

  def play(conn, %{"podcast" => podcast, "slug" => slug}) do
    podcast = Repo.get_by!(Podcast, slug: podcast)

    episode =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_podcast

    prev =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Episode.with_numbered_slug
      |> Episode.newest_first
      |> Episode.previous_to(episode)
      |> Episode.limit(1)
      |> Repo.one
      |> Episode.preload_podcast

    next =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Episode.with_numbered_slug
      |> Episode.newest_last
      |> Episode.next_after(episode)
      |> Episode.limit(1)
      |> Repo.one
      |> Episode.preload_podcast

    render conn, "play.json", podcast: podcast, episode: episode, prev: prev, next: next
  end
end
