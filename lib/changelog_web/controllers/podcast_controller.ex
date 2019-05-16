defmodule ChangelogWeb.PodcastController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, NewsItem, Podcast}

  def index(conn, _params) do
    render(conn, :index)
  end

  def show(conn, params = %{"slug" => slug}) do
    podcast = Podcast.get_by_slug!(slug)

    page =
      Podcast.get_news_items(podcast)
      |> NewsItem.published()
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.paginate(Map.put(params, :page_size, 30))

    items =
      page.entries
      |> Enum.map(&NewsItem.load_object/1)

    conn
    |> assign(:podcast, podcast)
    |> assign(:list, podcast.slug)
    |> assign(:items, items)
    |> assign(:page, page)
    |> cache_public(:timer.minutes(5))
    |> render(:show)
  end

  def popular(conn, params = %{"slug" => slug}) do
    podcast = Podcast.get_by_slug!(slug)

    page =
      Podcast.get_episodes(podcast)
      |> Episode.published()
      |> Episode.newer_than(~D[2016-10-10]) # modern era
      |> Episode.top_reach_first()
      |> Episode.exclude_transcript()
      |> Episode.preload_podcast()
      |> Repo.paginate(Map.put(params, :page_size, 10))

    items =
      Enum.map(page.entries, fn(episode) ->
        episode
        |> NewsItem.with_episode()
        |> NewsItem.preload_all()
        |> Repo.one()
        |> NewsItem.load_object(episode)
      end)

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
      |> Episode.preload_podcast()
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

  def upcoming(conn, params = %{"slug" => slug}) do
    podcast = Podcast.get_by_slug!(slug)

    page =
      Podcast.get_episodes(podcast)
      |> Episode.unpublished()
      |> NewsItem.newest_last(:recorded_at)
      |> Episode.preload_all()
      |> Episode.exclude_transcript()
      |> Repo.paginate(Map.put(params, :page_size, 10))

    items =
      page.entries
      |> Enum.map(fn(episode) ->
        item = %NewsItem{
          type: :audio,
          headline: episode.title,
          topics: episode.topics}
        Map.put(item, :object, episode)
      end)

    conn
    |> assign(:podcast, podcast)
    |> assign(:items, items)
    |> assign(:page, page)
    |> assign(:tab, "upcoming")
    |> render(:show)
  end
end
