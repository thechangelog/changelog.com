defmodule Changelog.HN do
  alias Changelog.HN.Client
  alias Changelog.{Episode, NewsItem}
  alias ChangelogWeb.EpisodeView

  def submit(%Episode{transcript: nil}), do: false

  def submit(episode = %Episode{}) do
    url = EpisodeView.transcript_url(episode)
    Client.submit(episode.title <> " (transcript)", url)
  end

  def submit(%NewsItem{feed_only: true}), do: false

  def submit(%NewsItem{type: :audio, headline: title, url: url}) do
    Client.submit(title <> " [audio]", url)
  end

  def submit(%NewsItem{headline: title, url: url}), do: Client.submit(title, url)
end
