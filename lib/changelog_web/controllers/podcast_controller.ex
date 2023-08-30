defmodule ChangelogWeb.PodcastController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, NewsItem, Podcast, Post}
  alias ChangelogWeb.Plug.ResponseCache

  plug ResponseCache

  def index(conn, _params) do
    render(conn, :index)
  end

  # here we create our meta-podcast, which is the merging of our 3 main podcasts
  def show(conn, params = %{"slug" => "podcast"}) do
    metapod_query =
      Enum.reduce(Podcast.changelog_ids(), NewsItem, fn id, query ->
        from(q in query, or_where: like(q.object_id, ^"#{id}:%"))
      end)

    page =
      metapod_query
      |> NewsItem.published()
      |> NewsItem.non_feed_only()
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.paginate(Map.put(params, :page_size, 30))

    items =
      page.entries
      |> Enum.map(&NewsItem.load_object/1)

    conn
    |> assign(:podcast, Podcast.changelog())
    |> assign(:items, items)
    |> assign(:trailer, nil)
    |> assign(:page, page)
    |> ResponseCache.cache_public(:timer.minutes(5))
    |> render(:show)
  end

  # front the "actual" show function with this one that tries to fetch a
  # podcast, then falls back to find a (legacy) post and redirect appropriately
  def show(conn, params = %{"slug" => slug}) do
    try do
      podcast = Podcast.get_by_slug!(slug)
      show(conn, params, podcast)
    rescue
      _e in Ecto.NoResultsError ->
        post = Post.published() |> Repo.get_by!(slug: slug)
        redirect(conn, to: ~p"/posts/#{post.slug}")
    end
  end

  def show(conn, params, podcast) do
    page =
      podcast
      |> Podcast.get_news_items()
      |> NewsItem.published()
      |> NewsItem.non_feed_only()
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.paginate(Map.put(params, :page_size, 30))

    items =
      page.entries
      |> Enum.map(&NewsItem.load_object/1)

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
    |> assign(:items, items)
    |> assign(:trailer, trailer)
    |> assign(:page, page)
    |> ResponseCache.cache_public(:timer.minutes(5))
    |> render(:show)
  end

  def popular(conn, params = %{"slug" => slug}) do
    podcast = Podcast.get_by_slug!(slug)

    page =
      podcast
      |> Podcast.get_episodes()
      |> Episode.published()
      # modern era
      |> Episode.newer_than(~D[2016-10-10])
      |> Episode.top_reach_first()
      |> Episode.exclude_transcript()
      |> Episode.preload_podcast()
      |> Repo.paginate(Map.put(params, :page_size, 10))

    # this is handled differently than 'recommended' because 'popular'
    # is an ordering whereas 'recommended' is a filter
    items =
      Enum.map(page.entries, fn episode ->
        episode
        |> NewsItem.with_episode()
        |> NewsItem.preload_all()
        |> Repo.one()
        |> NewsItem.load_object(episode)
      end)
      |> Enum.reject(&is_nil/1)

    conn
    |> assign(:podcast, podcast)
    |> assign(:items, items)
    |> assign(:page, page)
    |> assign(:tab, "popular")
    |> render(:show)
  end

  def recommended(conn, params = %{"slug" => slug}) do
    podcast = Podcast.get_by_slug!(slug)

    page =
      Podcast.get_episodes(podcast)
      |> Episode.published()
      |> Episode.featured()
      |> Episode.exclude_transcript()
      |> Repo.paginate(Map.put(params, :page_size, 30))

    items =
      page.entries
      |> NewsItem.with_episodes()
      |> NewsItem.published()
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.all()
      |> Enum.map(&NewsItem.load_object/1)

    conn
    |> assign(:podcast, podcast)
    |> assign(:items, items)
    |> assign(:page, page)
    |> assign(:tab, "recommended")
    |> render(:show)
  end
end
