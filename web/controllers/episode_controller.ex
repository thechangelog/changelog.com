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
      |> Episode.preload_all

    render(conn, :show, podcast: podcast, episode: episode)
  end

  def embed(conn, params = %{"podcast" => podcast, "slug" => slug}) do
    podcast = Repo.get_by!(Podcast, slug: podcast)

    episode =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_all

    conn
    |> put_layout(false)
    |> delete_resp_header("x-frame-options")
    |> render(:embed, podcast: podcast, episode: episode, theme: params["theme"] || "night")
  end

  def preview(conn, %{"podcast" => podcast, "slug" => slug}) do
    podcast = Repo.get_by!(Podcast, slug: podcast)

    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_all

    render(conn, :show, podcast: podcast, episode: episode)
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

    next =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Episode.with_numbered_slug
      |> Episode.newest_last
      |> Episode.next_after(episode)
      |> Episode.limit(1)
      |> Repo.one

    render(conn, "play.json", podcast: podcast, episode: episode, prev: preloaded(prev), next: preloaded(next))
  end

  defp preloaded(episode) when is_nil(episode), do: nil
  defp preloaded(episode), do: Episode.preload_podcast(episode)
end
