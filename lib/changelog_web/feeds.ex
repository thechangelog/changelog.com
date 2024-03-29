defmodule ChangelogWeb.Feeds do
  alias Changelog.{Episode, Fastly, Feed, NewsItem, Podcast, PodPing, Post, Repo}
  alias ChangelogWeb.{Endpoint, FeedView}
  alias ChangelogWeb.Router.Helpers, as: Routes

  @doc """
  Generates a fresh feed XML and uploads it to R2
  """
  def refresh(slug) do
    content = generate(slug)
    bucket = SecretOrEnv.get("R2_FEEDS_BUCKET", "changelog-feeds-dev")
    headers = [content_type: "application/xml"]
    key = "#{slug}.xml"

    ExAws.request!(ExAws.S3.put_object(bucket, key, content, headers))

    notify_services(slug)

    :ok
  end

  defp notify_services("feed") do
    url = Routes.feed_url(Endpoint, :news)
    Fastly.purge(url)
  end

  defp notify_services("posts") do
    url = Routes.feed_url(Endpoint, :posts)
    Fastly.purge(url)
  end

  defp notify_services("plusplus") do
    url = Routes.feed_url(Endpoint, :plusplus, Application.get_env(:changelog, :plusplus_slug))
    Fastly.purge(url)
  end

  defp notify_services(slug) do
    url = Routes.feed_url(Endpoint, :podcast, slug)
    Fastly.purge(url)
    PodPing.overcast(url)
  end

  @doc """
  Generates and returns the entire XML feed for given slug
  """
  def generate("feed") do
    items = NewsItem.latest_news_items()
    render("news.xml", items: items)
  end

  def generate("posts") do
    posts =
      Post.published()
      |> Post.newest_first()
      |> Post.limit(100)
      |> Post.preload_author()
      |> Repo.all()
      |> Enum.map(&Post.load_news_item/1)

    render("posts.xml", posts: posts)
  end

  def generate("plusplus") do
    podcast = Podcast.get_by_slug!("master")
    episodes = get_episodes(podcast)
    render("plusplus.xml", podcast: podcast, episodes: episodes)
  end

  # Special case for "The Changelog" feed which gets its episodes from
  # News, Friends & Interviews
  def generate("podcast") do
    podcast = Podcast.changelog()
    episodes = get_episodes(podcast)
    render("podcast.xml", podcast: podcast, episodes: episodes)
  end

  def generate(%Feed{} = feed) do
    episodes = get_episodes(feed)
    render("feed.xml", feed: feed, episodes: episodes)
  end

  def generate(%Podcast{} = podcast) do
    episodes = get_episodes(podcast)
    render("podcast.xml", podcast: podcast, episodes: episodes)
  end

  # When we have an unknown slug, look for a podcast followed by a feed
  def generate(slug) do
    generate(Podcast.get_by_slug(slug) || Feed.get_by_slug(slug))
  end

  defp get_episodes(%Feed{} = feed) do
    Episode
    |> Episode.with_ids(feed.podcast_ids, :podcast_id)
    |> Episode.published()
    |> Episode.newest_first()
    |> Episode.newer_than(feed.starts_at, :published_at)
    |> Episode.exclude_transcript()
    |> Episode.preload_all()
    |> Repo.all()
  end

  defp get_episodes(%Podcast{} = podcast) do
    podcast
    |> Podcast.get_episodes()
    |> Episode.published()
    |> Episode.newest_first()
    |> Episode.exclude_transcript()
    |> Episode.preload_all()
    |> Repo.all()
  end

  defp render(template, assigns) do
    assigns = [conn: Endpoint] ++ assigns
    Phoenix.View.render_to_string(FeedView, template, assigns)
  end
end
