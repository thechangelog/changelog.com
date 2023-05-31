defmodule Mix.Tasks.Changelog.PlusplusBonus do
  use Mix.Task

  alias Changelog.{Episode, Repo}
  alias ChangelogWeb.{EpisodeView, TimeView}

  @shortdoc "Prints a CSV of all episodes with a ++ bonus"

  def run(_) do
    Mix.Task.run("app.start")

    IO.puts "publish_date,podcast,episode,url"

    for episode <- Episode.published() |> Episode.newest_first() |> Repo.all() do
      if episode.plusplus_file && Enum.any?(episode.plusplus_chapters) do
        public_last = List.last(episode.audio_chapters)
        plusplus_last = List.last(episode.plusplus_chapters)

        if plusplus_last.title != public_last.title && String.match?(plusplus_last.title, ~r/bonus/i) do
          episode = Episode.preload_podcast(episode)
          IO.puts [
            TimeView.hacker_date(episode.published_at),
            episode.podcast.name,
            episode.title,
            EpisodeView.share_url(episode),
          ] |> Enum.join(",")
        end
      end
    end
  end
end
