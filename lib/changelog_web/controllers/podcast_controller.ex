defmodule ChangelogWeb.PodcastController do
  use ChangelogWeb, :controller

  alias Changelog.{Podcast, Episode, NewsItem}

  def index(conn, _params) do
    render(conn, :index)
  end

  def show(conn, params = %{"slug" => slug}) do
    podcast = Podcast.get_by_slug(slug)

    page =
      Podcast.get_news_items(podcast)
      |> NewsItem.published
      |> NewsItem.newest_first
      |> NewsItem.preload_all
      |> Repo.paginate(Map.put(params, :page_size, 30))

    items =
      page.entries
      |> Enum.map(&NewsItem.load_object/1)

    render(conn, :show, podcast: podcast, items: items, page: page)
  end

  def archive(conn, %{"slug" => slug}) do
    podcast = Podcast.get_by_slug(slug)

    episodes =
      Podcast.get_episodes(podcast)
      |> Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_podcast
      |> Episode.preload_guests

    render(conn, :archive, podcast: podcast, episodes: episodes)
  end
end
