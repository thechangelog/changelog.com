defmodule ChangelogWeb.Xml.Podcast do
  use ChangelogWeb, :verified_routes

  alias Changelog.{ListKit}
  alias ChangelogWeb.{EpisodeView, FeedView, PodcastView, TimeView, Xml}
  alias ChangelogWeb.Helpers.SharedHelpers

  @doc """
  Returns a full XML document structure ready to be sent to Xml.generate/1
  """
  def document(podcast, episodes) do
    {
      :rss,
      Xml.podcast_namespaces(),
      [channel(podcast, episodes)]
    }
    |> XmlBuilder.document()
  end

  def channel(podcast, episodes) do
    {
      :channel,
      nil,
      [
        {:title, nil, FeedView.podcast_name_with_metadata(podcast)},
        {:copyright, nil, "All rights reserved"},
        {:link, nil, FeedView.podcast_url(podcast)},
        {"atom:link",
         %{href: PodcastView.feed_url(podcast), rel: "self", type: "application/rss+xml"}},
        {"atom:link",
         %{href: FeedView.podcast_url(podcast), rel: "alternate", type: "text/html"}},
        {:language, nil, "en-us"},
        {:description, nil, FeedView.podcast_full_description(podcast)},
        {"itunes:summary", nil, FeedView.podcast_full_description(podcast)},
        {"itunes:explicit", nil, "false"},
        {"itunes:image", %{href: PodcastView.cover_url(podcast)}},
        {"itunes:author", nil, "Changelog Media"},
        {"itunes:owner", nil, Xml.itunes_owner()},
        {"itunes:keywords", nil, podcast.keywords},
        Xml.itunes_category(),
        Xml.itunes_sub_category(podcast),
        {"podcast:funding", %{url: "https://changelog.com/++"},
         "Support our work by joining Changelog++"},
        Enum.map(podcast.active_hosts, fn p -> Xml.person(p, "host") end),
        Enum.map(episodes, fn episode -> item(podcast, episode) end)
      ]
      |> List.flatten()
      |> ListKit.compact()
    }
  end

  def item(podcast, episode) do
    {:item, nil,
     [
       {:title, nil, FeedView.episode_title(podcast, episode)},
       {:guid, %{isPermaLink: false}, EpisodeView.guid(episode)},
       {:link, nil, url(~p"/#{episode.podcast.slug}/#{episode.slug}")},
       {:pubDate, nil, TimeView.rss(episode.published_at)},
       {:enclosure,
        %{url: EpisodeView.audio_url(episode), length: episode.audio_bytes, type: "audio/mpeg"}},
       {:description, nil, SharedHelpers.md_to_text(episode.summary)},
       {"itunes:episodeType", nil, episode.type},
       {"itunes:image", %{href: EpisodeView.cover_url(episode)}},
       {"itunes:duration", nil, TimeView.duration(episode.audio_duration)},
       {"itunes:explicit", nil, "false"},
       Enum.map(episode.hosts, fn p -> Xml.person(p, "host") end),
       Enum.map(episode.guests, fn p -> Xml.person(p, "guest") end),
       Xml.transcript(episode),
       chapters(episode),
       Xml.socialize(episode),
       {"content:encoded", nil, Xml.show_notes(episode, false)}
     ]}
  end

  defp chapters(%{audio_chapters: []}), do: nil

  defp chapters(episode = %{audio_chapters: chapters}) do
    [
      {"podcast:chapters",
       %{
         url: url(~p"/#{episode.podcast.slug}/#{episode.slug}/chapters"),
         type: "application/json+chapters"
       }},
      Xml.Chapters.chapters(chapters, "psc")
    ]
  end
end
