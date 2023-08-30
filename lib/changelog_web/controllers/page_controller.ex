defmodule ChangelogWeb.PageController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, NewsItem, Podcast, Subscription}
  alias ChangelogWeb.Plug.ResponseCache

  plug RequireGuest, "before joining" when action in [:join]
  plug ResponseCache

  # pages that need special treatment get their own matched function
  # all others simply render the template of the same name
  def action(conn, _) do
    case action_name(conn) do
      :guest -> guest(conn, Map.get(conn.params, "slug"))
      :index -> index(conn, conn.params)
      :sponsor -> sponsor(conn, conn.params)
      :sponsor_pricing -> sponsor_pricing(conn, conn.params)
      :sponsor_story -> sponsor_story(conn, Map.get(conn.params, "slug"))
      :++ -> plusplus(conn, conn.params)
      :plusplus -> plusplus(conn, conn.params)
      :manifest_json -> manifest_json(conn, conn.params)
      name -> render(conn, name)
    end
  end

  def guest(conn, slug) when is_nil(slug), do: guest(conn, "podcast")

  def guest(conn, slug) do
    active =
      Podcast.active()
      |> Podcast.oldest_first()
      |> Repo.all()

    podcast = Podcast.get_by_slug!(slug)

    episode =
      Podcast.get_episodes(podcast)
      |> Episode.published()
      |> Episode.newest_first()
      |> Episode.limit(1)
      |> Repo.one()
      |> Episode.preload_podcast()

    conn
    |> assign(:active, active)
    |> assign(:podcast, podcast)
    |> assign(:episode, episode)
    |> ResponseCache.cache_public()
    |> render(:guest)
  end

  def index(conn, params) do
    page =
      Podcast.master()
      |> Podcast.get_news_items()
      |> NewsItem.published()
      |> NewsItem.non_feed_only()
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.paginate(Map.put(params, :page_size, 10))

    items =
      page.entries
      |> Enum.map(&NewsItem.load_object/1)

    conn
    |> assign(:items, items)
    |> render(:index)
  end

  def manifest_json(conn, _params) do
    conn
    |> ResponseCache.cache_public()
    |> json(%{
      name: "Changelog",
      short_name: "Changelog",
      start_url: Routes.root_url(conn, :index),
      display: "standalone",
      description: "News and podcasts for developers",
      icons: [
          %{
              src: Routes.static_url(conn, "/android-chrome-192x192.png"),
              sizes: "192x192",
              type: "image/png"
          },
          %{
              src: Routes.static_url(conn, "/android-chrome-512x512.png"),
              sizes: "512x512",
              type: "image/png"
          }
      ],
      theme_color: "#ffffff",
      background_color: "#ffffff"
      })
  end

  def sponsor(conn, _params) do
    examples = Changelog.SponsorStory.examples()
    subs =
      Changelog.Cache.podcasts()
      |> Enum.find(&Podcast.is_news/1)
      |> Subscription.subscribed_count()

    render(conn, :sponsor, examples: examples, subs: subs)
  end

  def sponsor_pricing(conn, _params) do
    render(conn, :sponsor_pricing)
  end

  def sponsor_story(conn, slug) do
    story = Changelog.SponsorStory.get_by_slug(slug)
    render(conn, :sponsor_story, story: story)
  end

  def plusplus(conn, _params) do
    redirect(conn, external: Application.get_env(:changelog, :plusplus_url))
  end
end
