defmodule ChangelogWeb.FeedController do
  use ChangelogWeb, :controller

  require Logger

  alias Changelog.{AgentKit, Episode, NewsItem, NewsSource, Podcast, Post, Topic}

  plug PublicEtsCache

  def news(conn, _params) do
    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("news.xml", items: NewsItem.latest_news_items())
    |> cache_public_response(random_duration())
  end

  def news_titles(conn, _params) do
    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("news_titles.xml", items: NewsItem.latest_news_items())
    |> cache_public_response(random_duration())
  end

  def podcast(conn, %{"slug" => "backstage"}) do
    send_resp(conn, :not_found, "")
  end
  def podcast(conn, %{"slug" => slug}) do
    podcast = Podcast.get_by_slug!(slug)

    episodes =
      Podcast.get_episodes(podcast)
      |> Episode.published()
      |> Episode.newest_first()
      |> Episode.preload_all()
      |> Repo.all()
      |> Enum.map(&Episode.load_news_item/1)

    log_subscribers(conn, podcast)

    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("podcast.xml", podcast: podcast, episodes: episodes)
    |> cache_public_response(random_duration())
  end

  defp log_subscribers(conn, podcast) do
    ua = get_agent(conn)

    case AgentKit.get_subscribers(ua) do
      {:ok, {agent, subs}} -> Podcast.update_subscribers(podcast, agent, subs)
      {:error, :unknown_agent} -> Logger.info("Unknown agent reporting: #{ua}")
      {:error, _message} -> false
    end
  end

  def posts(conn, _params) do
    posts =
      Post.published()
      |> Post.newest_first()
      |> Post.limit(100)
      |> Post.preload_author()
      |> Repo.all()
      |> Enum.map(&Post.load_news_item/1)

    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("posts.xml", posts: posts)
    |> cache_public_response(random_duration())
  end

  def sitemap(conn, _params) do
    news_items =
      NewsItem.published()
      |> NewsItem.newest_first()
      |> Repo.all()

    news_sources =
      NewsSource
      |> Repo.all()

    episodes =
      Episode.published()
      |> Episode.newest_first()
      |> Repo.all()
      |> Episode.preload_podcast()

    podcasts =
      Podcast.public()
      |> Podcast.oldest_first()
      |> Podcast.preload_hosts()
      |> Repo.all()
      |> Kernel.++([Podcast.master])

    posts =
      Post.published()
      |> Post.newest_first()
      |> Repo.all()

    topics =
      Topic.with_news_items()
      |> Repo.all()

    conn
    |> put_layout(false)
    |> assign(:news_items, news_items)
    |> assign(:news_sources, news_sources)
    |> assign(:episodes, episodes)
    |> assign(:podcasts, podcasts)
    |> assign(:posts, posts)
    |> assign(:topics, topics)
    |> render("sitemap.xml")
    |> cache_public_response(random_duration())
  end

  defp random_duration, do: Enum.random(5..10) |> :timer.minutes()
end
