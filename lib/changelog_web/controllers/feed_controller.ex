defmodule ChangelogWeb.FeedController do
  use ChangelogWeb, :controller

  require Logger

  alias Changelog.{
    AgentKit,
    Episode,
    NewsItem,
    NewsSource,
    Person,
    Podcast,
    Post,
    Topic
  }

  alias ChangelogWeb.Plug.ResponseCache

  plug :log_subscribers, "log podcast subscribers" when action in [:podcast]
  plug ResponseCache

  def custom(conn, %{"slug" => slug}) do
    feed = ChangelogWeb.Feeds.generate(slug)
    send_xml_resp(conn, feed)
  end

  def news(conn, _params) do
    feed = ChangelogWeb.Feeds.generate("feed")
    send_xml_resp(conn, feed)
  end

  def news_titles(conn, _params) do
    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> assign(:items, NewsItem.latest_news_items())
    |> ResponseCache.cache_public(:timer.minutes(2))
    |> render("news_titles.xml")
  end

  def podcast(conn, %{"slug" => "backstage"}) do
    send_resp(conn, :not_found, "")
  end

  def podcast(conn, %{"slug" => slug}) do
    feed = ChangelogWeb.Feeds.generate(slug)
    send_xml_resp(conn, feed)
  end

  def plusplus(conn, %{"slug" => slug}) do
    if Application.get_env(:changelog, :plusplus_slug) == slug do
      feed = ChangelogWeb.Feeds.generate("plusplus")

      send_xml_resp(conn, feed)
    else
      send_resp(conn, :not_found, "")
    end
  end

  def posts(conn, _params) do
    feed = ChangelogWeb.Feeds.generate("posts")

    send_xml_resp(conn, feed)
  end

  def sitemap(conn, _params) do
    albums = Changelog.Album.all()

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
      Person.with_public_profile()
      |> Repo.all()

    podcasts =
      Podcast.public()
      |> Podcast.oldest_first()
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
    |> assign(:albums, albums)
    |> assign(:news_items, news_items)
    |> assign(:news_sources, news_sources)
    |> assign(:episodes, episodes)
    |> assign(:people, people)
    |> assign(:podcasts, podcasts)
    |> assign(:posts, posts)
    |> assign(:topics, topics)
    |> ResponseCache.cache_public(:timer.minutes(5))
    |> render("sitemap.xml")
  end

  defp send_xml_resp(conn, document) do
    conn
    |> put_layout(false)
    |> put_resp_header("access-control-allow-origin", "*")
    |> put_resp_content_type("application/xml")
    |> send_resp(200, document)
  end

  defp log_subscribers(conn = %{params: %{"slug" => slug}}, _) do
    ua = ChangelogWeb.Plug.Conn.get_agent(conn)

    case AgentKit.get_subscribers(ua) do
      {:ok, {agent, subs}} ->
        Logger.info("Known agent reporting: #{slug}, #{agent}, #{subs}")
        Podcast.update_subscribers(slug, agent, subs)

      {:error, :unknown_agent} ->
        Logger.info("Unknown agent reporting: #{ua}")

      {:error, _message} ->
        false
    end

    conn
  end
end
