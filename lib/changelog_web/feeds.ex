defmodule ChangelogWeb.Feeds do
  import Ecto.Query, only: [from: 2]

  alias Changelog.{Episode, NewsItem, Podcast, Repo}
  alias ChangelogWeb.{Endpoint, FeedView}

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

    render(podcast, episodes)
  end

  def generate("interviews") do
    podcast = Podcast.get_by_slug!("podcast")
    episodes = get_episodes(podcast)
    render(podcast, episodes)
  end

  def generate(slug) do
    podcast = Podcast.get_by_slug!(slug)
    episodes = get_episodes(podcast)
    render(podcast, episodes)
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

  defp render(podcast, episodes, template \\ "podcast.xml") do
    Phoenix.View.render_to_string(FeedView, template, conn: Endpoint, podcast: podcast, episodes: episodes)
  end
end
