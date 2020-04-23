defmodule Mix.Tasks.Changelog.News.Historic do
  use Mix.Task

  import ChangelogWeb.Router.Helpers
  alias ChangelogWeb.Router.Helpers, as: Routes

  alias Changelog.{Episode, NewsItem, Person, Post, Repo, UrlKit}
  alias ChangelogWeb.{Endpoint}

  @shortdoc "Generates news items for all historic episodes and posts"

  def run(_) do
    Mix.Task.run("app.start")
    create_news_items_for_episodes()
    create_news_items_for_posts()
  end

  defp create_news_items_for_episodes do
    logbot = Repo.get_by!(Person, handle: "logbot")
    episodes =
      Episode.published
      |> Episode.preload_all
      |> Repo.all

    for episode <- episodes do
      url = "https://changelog.com" <> episode_path(Endpoint, :show, episode.podcast.slug, episode.slug)
      topics = Enum.map(episode.episode_topics, &(Map.take(&1, [:position, :topic_id])))

      if Repo.count(NewsItem.with_url(url)) == 0 do
        changeset = NewsItem.insert_changeset(%NewsItem{}, %{
          logger_id: logbot.id,
          status: :published,
          type: :audio,
          url: url,
          headline: episode.title,
          story: episode.summary,
          object_id: UrlKit.get_object_id("audio", url),
          published_at: episode.published_at,
          news_item_topics: topics
        })

        IO.puts "Inserting item for url: #{url}"
        Repo.insert(changeset)
      else
        IO.puts "Skipping item for url: #{url}"
      end
    end
  end

  defp create_news_items_for_posts do
    logbot = Repo.get_by!(Person, handle: "logbot")
    posts =
      Post.published
      |> Post.preload_all
      |> Repo.all

    for post <- posts do
      url = "https://changelog.com" <> post_path(Endpoint, :show, post.slug)
      topics = Enum.map(post.post_topics, &(Map.take(&1, [:position, :topic_id])))

      if Repo.count(NewsItem.with_url(url)) == 0 do
        changeset = NewsItem.insert_changeset(%NewsItem{}, %{
          logger_id: logbot.id,
          status: :published,
          type: :link,
          url: url,
          headline: post.title,
          story: (post.tldr || post.body),
          object_id: UrlKit.get_object_id("link", url),
          published_at: post.published_at,
          news_item_topics: topics
        })

        IO.puts "Inserting item for url: #{url}"
        Repo.insert(changeset)
      else
        IO.puts "Skipping item for url: #{url}"
      end
    end
  end
end
