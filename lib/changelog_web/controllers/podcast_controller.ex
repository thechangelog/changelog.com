defmodule ChangelogWeb.PodcastController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, Podcast, Post, Subscription}

  def index(conn, _params) do
    render(conn, :index)
  end

  def archive(conn, %{"slug" => "news"}) do
    podcast = get_podcast_by_slug("news")

    issues =
      podcast
      |> Podcast.get_episodes()
      |> Episode.published()
      |> Episode.newest_first()
      |> Episode.preload_podcast()
      |> Repo.all()

    sub_count = Subscription.subscribed_count(podcast)

    conn
    |> assign(:sub_count, sub_count)
    |> assign(:podcast, podcast)
    |> assign(:issues, issues)
    |> render(:archive, layout: {ChangelogWeb.LayoutView, "news.html"})
  end

  # Changelog News is the only podcast with an archive
  def archive(conn, %{"slug" => slug}) do
    redirect(conn, to: ~p"/#{slug}")
  end

  # front the "actual" show function with this one that tries to fetch a
  # podcast, then falls back to find a (legacy) post and redirect appropriately
  def show(conn, params = %{"slug" => slug}) do
    try do
      podcast = get_podcast_by_slug(slug)
      show(conn, params, podcast)
    rescue
      _e in Ecto.NoResultsError ->
        post = Post.published() |> Repo.get_by!(slug: slug)
        redirect(conn, to: ~p"/posts/#{post.slug}")
    end
  end

  # Changelog News gets its own special treatment
  def show(conn, _params, podcast = %{slug: "news"}) do
    [latest, previous] =
      podcast
      |> Podcast.get_episodes()
      |> Episode.published()
      |> Episode.newest_first()
      |> Episode.limit(2)
      |> Episode.preload_podcast()
      |> Repo.all()

    sub_count = Subscription.subscribed_count(podcast)

    conn
    |> assign(:sub_count, sub_count)
    |> assign(:podcast, podcast)
    |> assign(:episode, latest)
    |> assign(:previous, previous)
    |> render(:news, layout: {ChangelogWeb.LayoutView, "news.html"})
  end

  def show(conn, params, podcast) do
    page =
      podcast
      |> Podcast.get_episodes()
      |> Episode.published()
      |> Episode.newest_first()
      |> Episode.preload_all()
      |> Repo.paginate(Map.put(params, :page_size, 30))

    trailer =
      podcast
      |> assoc(:episodes)
      |> Episode.trailer()
      |> Episode.published()
      |> Episode.limit(1)
      |> Episode.preload_podcast()
      |> Repo.one()

    conn
    |> assign(:podcast, podcast)
    |> assign(:trailer, trailer)
    |> assign(:page, page)
    |> render(:show)
  end

  def popular(conn, params = %{"slug" => slug}) do
    podcast = get_podcast_by_slug(slug)

    page =
      podcast
      |> Podcast.get_episodes()
      |> Episode.published()
      # modern era
      |> Episode.newer_than(~D[2016-10-10])
      |> Episode.top_downloaded_first()
      |> Episode.preload_all()
      |> Episode.exclude_transcript()
      |> Repo.paginate(Map.put(params, :page_size, 30))

    conn
    |> assign(:podcast, podcast)
    |> assign(:page, page)
    |> assign(:tab, "popular")
    |> render(:show)
  end

  def recommended(conn, params = %{"slug" => slug}) do
    podcast = get_podcast_by_slug(slug)

    page =
      Podcast.get_episodes(podcast)
      |> Episode.published()
      |> Episode.featured()
      |> Episode.newest_first()
      |> Episode.preload_all()
      |> Episode.exclude_transcript()
      |> Repo.paginate(Map.put(params, :page_size, 30))

    conn
    |> assign(:podcast, podcast)
    |> assign(:page, page)
    |> assign(:tab, "recommended")
    |> render(:show)
  end

  defp get_podcast_by_slug(slug) do
    case slug do
      "podcast" -> Podcast.changelog()
      slug -> Podcast.get_by_slug!(slug)
    end
  end
end
