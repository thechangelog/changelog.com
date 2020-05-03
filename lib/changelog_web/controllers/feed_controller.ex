defmodule ChangelogWeb.FeedController do
  use ChangelogWeb, :controller

  require Logger

  alias Changelog.{AgentKit, Episode, NewsItem, NewsSource, Person, Podcast, Post, Topic}

  def news(conn, _params) do
    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> assign(:items, NewsItem.latest_news_items())
    |> ResponseCache.cache_public(cache_duration())
    |> render("news.xml")
  end

  def news_titles(conn, _params) do
    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> assign(:items, NewsItem.latest_news_items())
    |> ResponseCache.cache_public(cache_duration())
    |> render("news_titles.xml")
  end

  def podcast(conn, %{"slug" => "backstage"}) do
    send_resp(conn, :not_found, "")
  end

  def podcast(conn, params = %{"slug" => slug}) do
    podcast = Podcast.get_by_slug!(slug)

    page =
      podcast
      |> Podcast.get_episodes()
      |> Episode.published()
      |> Episode.newest_first()
      |> Episode.exclude_transcript()
      |> Episode.preload_all()
      |> Repo.paginate(Map.put(params, :page_size, 100))

    log_subscribers(conn, podcast)

    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> assign(:page, page)
    |> assign(:podcast, podcast)
    |> assign(:episodes, page.entries)
    |> ResponseCache.cache_public(cache_duration())
    |> render("podcast.xml")
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
    |> ResponseCache.cache_public(cache_duration())
    |> render("posts.xml", posts: posts)
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
      |> Episode.exclude_transcript()
      |> Episode.preload_podcast()
      |> Repo.all()

    people =
      Person.with_profile()
      |> Repo.all()

    podcasts =
      Podcast.public()
      |> Podcast.oldest_first()
      |> Podcast.preload_hosts()
      |> Repo.all()
      |> Kernel.++([Podcast.master()])

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
    |> assign(:people, people)
    |> assign(:podcasts, podcasts)
    |> assign(:posts, posts)
    |> assign(:topics, topics)
    |> ResponseCache.cache_public(cache_duration())
    |> render("sitemap.xml")
  end

  defp cache_duration, do: 2..10 |> Enum.random() |> :timer.minutes()
end
