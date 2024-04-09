defmodule ChangelogWeb.Feeds do
  use ChangelogWeb, :verified_routes

  alias Changelog.{Episode, Fastly, Feed, NewsItem, Podcast, PodPing, Post, Repo}
  alias ChangelogWeb.{Endpoint, FeedView}

  @doc """
  Generates a fresh feed XML and uploads it to R2
  """
  def refresh(feed = %Feed{slug: slug}) do
    content = generate(feed)
    upload(content, slug)
    notify_services(feed)

    :ok
  end

  def refresh(slug) do
    content = generate(slug)
    upload(content, slug)
    notify_services(slug)

    :ok
  end

  defp upload(content, key) do
    bucket = SecretOrEnv.get("R2_FEEDS_BUCKET", "changelog-feeds-dev")
    headers = [content_type: "application/xml"]
    file = "#{key}.xml"

    bucket
    |> ExAws.S3.put_object(file, content, headers)
    |> ExAws.request!()
  end

  defp notify_services("feed"), do: Fastly.purge(url(~p"/feed"))

  defp notify_services("posts"), do: Fastly.purge(url(~p"/posts/feed"))

  defp notify_services("plusplus") do
    slug = Application.get_env(:changelog, :plusplus_slug)
    Fastly.purge(url(~p"/plusplus/#{slug}/feed"))
  end

  defp notify_services(feed_or_slug) do
    feed_url =
      case feed_or_slug do
        %Feed{slug: slug} -> url(~p"/feeds/#{slug}")
        slug -> url(~p"/#{slug}/feed")
      end

    Fastly.purge(feed_url)
    PodPing.overcast(feed_url)
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
  def generate("podcast"), do: generate(Podcast.changelog())

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
    generate(Podcast.get_by_slug(slug) || Feed.get_by_slug!(slug))
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
