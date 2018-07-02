defmodule ChangelogWeb.EpisodeController do
  use ChangelogWeb, :controller

  alias Changelog.{Podcast, Episode}

  plug :assign_podcast

  def action(conn, _) do
    arg_list = [conn, conn.params, conn.assigns.podcast]
    apply(__MODULE__, action_name(conn), arg_list)
  end

  def show(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Episode.preload_all
      |> Repo.get_by!(slug: slug)

    render(conn, :show, podcast: podcast, episode: episode)
  end

  def embed(conn, params = %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_all

    theme = Map.get(params, "theme", "night")
    source = Map.get(params, "source", "default")

    conn
    |> put_layout(false)
    |> delete_resp_header("x-frame-options")
    |> render(:embed, podcast: podcast, episode: episode, theme: theme, source: source)
  end

  def preview(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_all

    render(conn, :show, podcast: podcast, episode: episode)
  end

  def play(conn, %{"slug" => slug}, podcast) do
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

  def share(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_podcast

    render(conn, "share.json", podcast: podcast, episode: episode)
  end

  defp assign_podcast(conn, _) do
    podcast = Repo.get_by!(Podcast, slug: conn.params["podcast"])
    assign(conn, :podcast, podcast)
  end

  defp preloaded(episode) when is_nil(episode), do: nil
  defp preloaded(episode), do: Episode.preload_podcast(episode)
end
