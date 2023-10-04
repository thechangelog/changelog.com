defmodule ChangelogWeb.Feeds do
  import Ecto.Query, only: [from: 2]

  alias Changelog.{Episode, Fastly, NewsItem, Podcast, PodPing, Post, Repo}
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

    episodes =
      Podcast.changelog_ids()
        |> Enum.reduce(NewsItem, fn id, query ->
          from(q in query, or_where: like(q.object_id, ^"#{id}:%"))
        end)
        |> Ecto.Query.select([:object_id])
        |> Repo.all()
        |> Enum.map(fn i ->
          i.object_id
          |> String.split(":")
          |> List.last()
        end)
        |> Episode.with_ids()
        |> Episode.published()
        |> Episode.newest_first()
        |> Episode.exclude_transcript()
        |> Episode.preload_all()
        |> Repo.all()

    render("podcast.xml", podcast: podcast, episodes: episodes)
  end

  # All other podcasts
  def generate(slug) do
    podcast = Podcast.get_by_slug!(slug)
    episodes = get_episodes(podcast)
    render("podcast.xml", podcast: podcast, episodes: episodes)
  end

  defp get_episodes(podcast) do
    podcast
    |> Podcast.get_news_item_episode_ids!()
    |> Episode.with_ids()
    |> Episode.published()
    |> Episode.newest_first()
    |> Episode.exclude_transcript()
    |> Episode.preload_all()
    |> Repo.all()
  end

  # defp render(podcast, episodes, template \\ "podcast.xml") do
  defp render(template, assigns) do
    assigns = [conn: Endpoint] ++ assigns
    Phoenix.View.render_to_string(FeedView, template, assigns)
  end
end
