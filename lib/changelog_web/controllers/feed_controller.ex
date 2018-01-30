defmodule ChangelogWeb.FeedController do
  use ChangelogWeb, :controller
  use PlugEtsCache.Phoenix

  alias Changelog.{Episode, NewsItem, NewsSource, Podcast, Post, Topic}

  require Logger

  def news(conn, _params) do
    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("news.xml", items: get_news_items())
    |> cache_response
  end

  def news_titles(conn, _params) do
    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("news_titles.xml", items: get_news_items())
    |> cache_response
  end

  def podcast(conn, %{"slug" => slug}) do
    podcast = Podcast.get_by_slug(slug)

    episodes =
      Podcast.get_episodes(podcast)
      |> Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_all

    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("podcast.xml", podcast: podcast, episodes: episodes)
    |> cache_response
  end

  def posts(conn, _params) do
    posts =
      Post.published
      |> Post.newest_first
      |> Post.limit(100)
      |> Repo.all
      |> Post.preload_author

    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("posts.xml", posts: posts)
    |> cache_response
  end

  def sitemap(conn, _params) do
    news_items =
      NewsItem.published
      |> NewsItem.newest_first
      |> Repo.all

    news_sources =
      NewsSource
      |> Repo.all

    episodes =
      Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_podcast

    podcasts =
      Podcast.public
      |> Podcast.oldest_first
      |> Repo.all
      |> Podcast.preload_hosts

    posts =
      Post.published
      |> Post.newest_first
      |> Repo.all

    topics =
      Topic.with_news_items
      |> Repo.all

    conn
    |> put_layout(false)
    |> render("sitemap.xml", news_items: news_items, news_sources: news_sources, episodes: episodes, podcasts: podcasts, posts: posts, topics: topics)
    |> cache_response
  end

  defp get_news_items do
    NewsItem
    |> NewsItem.published
    |> NewsItem.newest_first
    |> NewsItem.preload_all
    |> NewsItem.limit(50)
    |> Repo.all
    |> Enum.map(&NewsItem.load_object/1)
  end
end
