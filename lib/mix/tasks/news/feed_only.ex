defmodule Mix.Tasks.Changelog.News.FeedOnly do
  use Mix.Task

  alias Changelog.{Episode, EpisodeNewsItem, NewsItem, Person, Repo}

  @shortdoc "Generates news items for historic feed-only episodes"

  def run(_) do
    Mix.Task.run("app.start")
    create_news_items_for_episodes()
  end

  defp create_news_items_for_episodes do
    logbot = Repo.get_by!(Person, handle: "logbot")

    episodes =
      Episode.published()
      |> Episode.preload_all()
      |> Repo.all()

    for episode <- episodes do
      if !Episode.has_news_item(episode) do
        episode
        |> EpisodeNewsItem.insert(logbot, true)
        |> NewsItem.publish!()
      end
    end
  end
end
