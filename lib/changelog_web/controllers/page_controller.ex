defmodule ChangelogWeb.PageController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, Podcast, Subscription}

  plug RequireGuest, "before joining" when action in [:join]

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
    |> render(:guest)
  end

  def index(conn, params) do
    page =
      Podcast.master()
      |> Podcast.get_episodes()
      |> Episode.published()
      |> Episode.newest_first()
      |> Episode.preload_all()
      |> Repo.paginate(Map.put(params, :page_size, 10))

    conn
    |> assign(:page, page)
    |> render(:index)
  end

  def manifest_json(conn, _params) do
    conn
    |> json(%{
      name: "Changelog",
      short_name: "Changelog",
      start_url: url(~p"/"),
      display: "standalone",
      description: "News and podcasts for developers",
      icons: [
          %{
              src: url(~p"/android-chrome-192x192.png"),
              sizes: "192x192",
              type: "image/png"
          },
          %{
              src: url(~p"/android-chrome-512x512.png"),
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
