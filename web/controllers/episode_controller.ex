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
end
