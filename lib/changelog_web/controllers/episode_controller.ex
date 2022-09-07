defmodule ChangelogWeb.EpisodeController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, NewsItem, Podcast, Subscription}
  alias ChangelogWeb.Plug.ResponseCache
  alias ChangelogWeb.{LiveView, TimeView}

  plug ResponseCache
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
    |> ResponseCache.cache_public(:timer.minutes(5))
    |> render(:show)
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
    |> ResponseCache.cache_public(:infinity)
    |> render(:embed)
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
      |> Episode.preload_podcast()
      |> Repo.get_by!(slug: slug)

    prev =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Episode.with_numbered_slug()
      |> Episode.newest_first()
      |> Episode.previous_to(episode)
      |> Episode.limit(1)
      |> Episode.preload_podcast()
      |> Repo.one()

    next =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Episode.with_numbered_slug()
      |> Episode.newest_last()
      |> Episode.next_after(episode)
      |> Episode.limit(1)
      |> Episode.preload_podcast()
      |> Repo.one()

    conn
    |> assign(:podcast, podcast)
    |> assign(:episode, episode)
    |> assign(:prev, prev)
    |> assign(:next, next)
    |> render("play.json")
  end

  def share(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Episode.preload_podcast()
      |> Repo.get_by!(slug: slug)

    render(conn, "share.json", podcast: podcast, episode: episode)
  end

  def discuss(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Episode.preload_podcast()
      |> Repo.get_by!(slug: slug)

    if item = Episode.get_news_item(episode) do
      redirect(conn, to: Routes.news_item_path(conn, :show, NewsItem.slug(item)))
    else
      redirect(conn, to: Routes.episode_path(conn, :show, podcast.slug, episode.slug))
    end
  end

  def transcript(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Episode.with_transcript()
      |> Episode.preload_all()
      |> Repo.get_by!(slug: slug)

    conn
    |> assign(:podcast, podcast)
    |> assign(:episode, episode)
    |> ResponseCache.cache_public(:infinity)
    |> render(:transcript, layout: false)
  end

  def chapters(conn, params = %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.published()
      |> Repo.get_by!(slug: slug)

    chapters = if Map.has_key?(params, "pp") do
      episode.plusplus_chapters
    else
      episode.audio_chapters
    end

    conn
    |> assign(:chapters, chapters)
    |> render("chapters.json")
  end

  def live(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.recorded_live()
      |> Episode.with_youtube_id()
      |> Repo.get_by!(slug: slug)

    redirect(conn, external: LiveView.youtube_url(episode))
  end

  def time(conn, %{"slug" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.recorded_live_at_known_time()
      |> Repo.get_by!(slug: slug)

    redirect(conn, external: TimeView.time_is_url(episode.recorded_at))
  end

  def subscribe(conn = %{method: "POST", assigns: %{current_user: me}}, %{"slug" => slug}, podcast) do
    episode =
      podcast
      |> assoc(:episodes)
      |> Episode.published()
      |> Repo.get_by!(slug: slug)

    context = "you clicked the link to be notified on changelog.com"
    Subscription.subscribe(me, episode, context)

    conn
    |> put_flash(:success, "We'll email you when the transcript is published 📥")
    |> redirect(to: Routes.episode_path(conn, :show, podcast.slug, episode.slug))
  end

  def unsubscribe(conn = %{method: "POST", assigns: %{current_user: me}}, %{"slug" => slug}, podcast) do
    episode =
      podcast
      |> assoc(:episodes)
      |> Episode.published()
      |> Repo.get_by!(slug: slug)

    Subscription.unsubscribe(me, episode)

    conn
    |> put_flash(:success, "You're no longer subscribed. Resubscribe any time 🤗")
    |> redirect(to: Routes.episode_path(conn, :show, podcast.slug, episode.slug))
  end

  defp assign_podcast(conn, _) do
    podcast = Repo.get_by!(Podcast, slug: conn.params["podcast"])
    assign(conn, :podcast, podcast)
  end
end
