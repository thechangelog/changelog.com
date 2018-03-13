defmodule ChangelogWeb.PodcastController do
  use ChangelogWeb, :controller

  alias Changelog.{Podcast, NewsItem}

  def index(conn, _params) do
    active =
      Podcast.active
      |> Podcast.oldest_first
      |> Podcast.preload_hosts
      |> Repo.all
      |> Kernel.++([Podcast.master])

    retired =
      Podcast.retired
      |> Podcast.oldest_first
      |> Podcast.preload_hosts
      |> Repo.all

    render(conn, :index, active: active, retired: retired)
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

    render(conn, :show, podcast: podcast, items: items, page: page, list: podcast.slug)
  end
end
