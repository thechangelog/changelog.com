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
      |> NewsItem.published
      |> NewsItem.newest_first
      |> NewsItem.preload_all
      |> Repo.paginate(Map.put(params, :page_size, 30))

    items =
      page.entries
      |> Enum.map(&NewsItem.load_object/1)

    render(conn, :show, podcast: podcast, list: podcast.slug, items: items, page: page)
  end

  def recommended(conn, params = %{"slug" => slug}) do
    podcast = Podcast.get_by_slug!(slug)

    page =
      Podcast.get_episodes(podcast)
      |> Episode.published
      |> Episode.featured
      |> Episode.preload_podcast
      |> Repo.paginate(Map.put(params, :page_size, 30))

    items =
      page.entries
      |> NewsItem.with_episodes
      |> NewsItem.published
      |> NewsItem.newest_first
      |> NewsItem.preload_all
      |> Repo.all
      |> Enum.map(&NewsItem.load_object/1)

    render(conn, :show, podcast: podcast, items: items, page: page, tab: "recommended")
  end

  def upcoming(conn, params = %{"slug" => slug}) do
    podcast = Podcast.get_by_slug!(slug)

    page =
      Podcast.get_episodes(podcast)
      |> Episode.unpublished
      |> NewsItem.newest_last(:recorded_at)
      |> Episode.preload_all
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

    render(conn, :show, podcast: podcast, items: items, page: page, tab: "upcoming")
  end
end
