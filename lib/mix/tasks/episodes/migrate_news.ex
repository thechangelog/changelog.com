defmodule Mix.Tasks.Changelog.MigrateNews do
  use Mix.Task

  alias Changelog.{Episode, Podcast, Repo}
  alias ChangelogWeb.EpisodeView

  import Ecto.Changeset, only: [change: 2]

  @shortdoc "Migrates all news episodes of The Changelog to Changelog News"

  def run(_) do
    Mix.Task.run("app.start")

    news = Podcast.get_by_slug!("news")

    Episode.published()
    |> Episode.with_slug_prefix("news-")
    |> Episode.newest_last()
    |> Repo.all()
    |> Enum.with_index(1)
    |> Enum.each(fn {episode, index} ->
      # Point the associated news item to the new pod
      episode
      |> Episode.get_news_item()
      |> change(%{
        object_id: "#{news.id}:#{episode.id}",
        url: "https://changelog.com/news/#{index}"
        })
      |> Repo.update!()

      # Change relevant data on the episode itself
      episode
      |> change(%{
        guid: EpisodeView.guid(episode),
        podcast_id: news.id,
        slug: "#{index}",
        subtitle: ""
      })
      |> Repo.update!()

      # Point all associated episode stat records to the new pod
      episode
      |> Ecto.assoc(:episode_stats)
      |> Repo.all()
      |> Enum.each(fn stat ->
        stat
        |> change(%{podcast_id: news.id})
        |> Repo.update!()
      end)
    end)
  end
end
