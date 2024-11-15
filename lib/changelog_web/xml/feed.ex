defmodule ChangelogWeb.Xml.Feed do
  use ChangelogWeb, :verified_routes

  alias Changelog.{ListKit}
  alias ChangelogWeb.{EpisodeView, FeedView, PodcastView, TimeView, Xml}
  alias ChangelogWeb.Helpers.SharedHelpers

  @doc """
  Returns a full XML document structure ready to be sent to Xml.generate/1
  """
  def document(feed, episodes) do
    {
      :rss,
      Xml.podcast_namespaces(),
      [channel(feed, episodes)]
    }
    |> XmlBuilder.document()
  end

  def channel(feed, episodes) do
    {
      :channel,
      nil,
      [
        {:title, nil, feed.name},
        {:copyright, nil, "All rights reserved"},
        {:language, nil, "en-us"},
        {:description, nil, feed.description || " "},
        {"itunes:author", nil, "Changelog Media"},
        {"itunes:block", nil, "yes"},
        {"itunes:explicit", nil, "false"},
        {"itunes:summary", nil, feed.description || " "},
        {"itunes:image", %{href: PodcastView.cover_url(feed)}},
        {"itunes:owner", nil, Xml.itunes_owner()},
        Enum.map(episodes, fn episode -> item(feed, episode) end)
      ]
      |> List.flatten()
      |> ListKit.compact()
    }
  end

  def item(feed, episode) do
    {:item, nil,
     [
       {:title, nil, FeedView.custom_episode_title(feed, episode)},
       {:guid, %{isPermaLink: false}, EpisodeView.guid(episode)},
       {:link, nil, url(~p"/#{episode.podcast.slug}/#{episode.slug}")},
       {:pubDate, nil, TimeView.rss(episode.published_at)},
       {:enclosure, enclosure(feed, episode)},
       {:description, nil, SharedHelpers.md_to_text(episode.summary)},
       {"itunes:episodeType", nil, episode.type},
       {"itunes:image", %{href: EpisodeView.cover_url(episode)}},
       {"itunes:duration", nil, duration(feed, episode)},
       {"itunes:explicit", nil, "false"},
       {"itunes:subtitle", nil, episode.subtitle},
       {"itunes:summary", nil, SharedHelpers.md_to_text(episode.summary)},
       Enum.map(episode.hosts, fn p -> Xml.person(p, "host") end),
       Enum.map(episode.guests, fn p -> Xml.person(p, "guest") end),
       Xml.transcript(episode),
       chapters(feed, episode),
       Xml.socialize(episode),
       {"content:encoded", nil, Xml.show_notes(episode, feed.plusplus)}
     ]}
  end

  defp duration(feed, episode) do
    t =
      if feed.plusplus do
        episode.plusplus_duration
      else
        episode.audio_duration
      end

    TimeView.duration(t)
  end

  defp enclosure(feed, episode) do
    {url, bytes} =
      if feed.plusplus do
        {EpisodeView.plusplus_url(episode), episode.plusplus_bytes}
      else
        {EpisodeView.audio_url(episode), episode.audio_bytes}
      end

    %{url: url, length: bytes, type: "audio/mpeg"}
  end

  defp chapters(_feed, %{audio_chapters: []}), do: nil

  defp chapters(feed, episode) do
    {chapters, url} =
      if feed.plusplus && Enum.any?(episode.plusplus_chapters) do
        {episode.plusplus_chapters,
         url(~p"/#{episode.podcast.slug}/#{episode.slug}/chapters?pp=true")}
      else
        {episode.audio_chapters, url(~p"/#{episode.podcast.slug}/#{episode.slug}/chapters")}
      end

    [
      {"podcast:chapters",
       %{
         url: url,
         type: "application/json+chapters"
       }},
      Xml.Chapters.chapters(chapters, "psc")
    ]
  end
end
