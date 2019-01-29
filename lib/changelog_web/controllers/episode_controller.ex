defmodule ChangelogWeb.EpisodeController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, Podcast}

  plug :allow_framing, "embeds are frameable" when action in [:embed]
  plug PublicEtsCache
  plug :assign_podcast

  def action(conn, _) do
    arg_list = [conn, conn.params, conn.assigns.podcast]
    apply(__MODULE__, action_name(conn), arg_list)
  end

  def show(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Episode.preload_all()
      |> Repo.get_by!(slug: slug)
      |> Episode.load_news_item()

    conn
    |> assign(:podcast, podcast)
    |> assign(:episode, episode)
    |> assign(:item, episode.news_item)
    |> render(:show)
    |> cache_public_response(:infinity)
  end

  def embed(conn, params = %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Episode.preload_all()
      |> Repo.get_by!(slug: slug)

    theme = Map.get(params, "theme", "night")
    source = Map.get(params, "source", "default")

    conn
    |> put_layout(false)
    |> assign(:podcast, podcast)
    |> assign(:episode, episode)
    |> assign(:theme, theme)
    |> assign(:source, source)
    |> render(:embed)
    |> cache_public_response(:infinity)
  end

  def preview(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.preload_all()
      |> Repo.get_by!(slug: slug)

    conn
    |> assign(:podcast, podcast)
    |> assign(:episode, episode)
    |> assign(:item, nil)
    |> render(:show)
  end

  def play(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
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

  defp allow_framing(conn, _), do: delete_resp_header(conn, "x-frame-options")

  defp assign_podcast(conn, _) do
    podcast = Repo.get_by!(Podcast, slug: conn.params["podcast"])
    assign(conn, :podcast, podcast)
  end

  defp preloaded(episode) when is_nil(episode), do: nil
  defp preloaded(episode), do: Episode.preload_podcast(episode)
end
