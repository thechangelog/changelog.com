defmodule ChangelogWeb.Xml.Feed do
  use ChangelogWeb, :verified_routes

  alias Changelog.{Episode, ListKit}
  alias ChangelogWeb.{EpisodeView, FeedView, PersonView, PodcastView, TimeView, Xml}
  alias ChangelogWeb.Helpers.SharedHelpers

  @doc """
  Returns a full XML document structure ready to be sent to Xml.generate/1
  """
  def document(feed, episodes) do
    {
      :rss,
      %{
        version: "2.0",
        "xmlns:content": "http://purl.org/rss/1.0/modules/content/",
        "xmlns:itunes": "http://www.itunes.com/dtds/podcast-1.0.dtd",
        "xmlns:podcast": "https://podcastindex.org/namespace/1.0",
        "xmlns:psc": "http://podlove.org/simple-chapters"
      },
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
        {:description, nil, feed.description},
        {"itunes:author", nil, "Changelog Media"},
        {"itunes:block", nil, "yes"},
        {"itunes:explicit", nil, "no"},
        {"itunes:summary", nil, feed.description},
        {"itunes:image", %{href: PodcastView.cover_url(feed)}},
        {"itunes:owner", nil, itunes_owner()},
        Enum.map(episodes, fn episode -> episode(feed, episode) end)
      ]
      |> List.flatten()
      |> ListKit.compact()
    }
  end

  def episode(feed, episode) do
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
       {"itunes:explicit", nil, "no"},
       {"itunes:subtitle", nil, episode.subtitle},
       {"itunes:summary", nil, SharedHelpers.md_to_text(episode.summary)},
       Enum.map(episode.hosts, fn p -> person(p, "host") end),
       Enum.map(episode.guests, fn p -> person(p, "guest") end),
       transcript(episode),
       chapters(feed, episode),
       socialize(episode),
       {"content:encoded", nil, show_notes(episode)}
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
      if feed.plusplus do
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

  defp itunes_owner do
    [{"itunes:name", nil, "Changelog Media"}, {"itunes:email", nil, "editors@changelog.com"}]
  end

  defp person(person, role) do
    {"podcast:person",
     %{
       role: role,
       img: PersonView.avatar_url(person, :large),
       href: PersonView.profile_url(person)
     }, person.name}
  end

  defp show_notes(episode) do
    sponsors = episode.episode_sponsors
    participants = EpisodeView.participants(episode)

    data =
      [
        SharedHelpers.md_to_html(episode.summary),
        FeedView.discussion_link(episode),
        ~s(<p><a href="#{url(~p"/++")}" rel="payment">Changelog++</a> #{EpisodeView.plusplus_cta(episode)} Join today!</p>),
        show_notes_sponsors(sponsors),
        show_notes_featuring(participants),
        "<p>Show Notes:</p>",
        "<p>#{SharedHelpers.md_to_html(episode.notes)}</p>",
        ~s(<p>Something missing or broken? <a href="#{EpisodeView.show_notes_source_url(episode)}">PRs welcome!</a></p>)
      ]
      |> ListKit.compact_join("")

    {:cdata, data}
  end

  defp show_notes_sponsors([]), do: nil

  defp show_notes_sponsors(sponsors) do
    items =
      Enum.map(sponsors, fn s ->
        description = s.description |> SharedHelpers.md_to_html() |> SharedHelpers.sans_p_tags()

        ~s"""
        <li><a href="#{s.link_url}">#{s.title}</a> – #{description}</li>
        """
      end)

    ["<p>Sponsors:</p><p><ul>", items, "</ul></p>"]
  end

  defp show_notes_featuring([]), do: nil

  defp show_notes_featuring(participants) do
    items =
      Enum.map(participants, fn p ->
        ~s"""
          <li>#{p.name} &ndash; #{PersonView.list_of_links(p)}</li>
        """
      end)

    ["<p>Featuring:</p><ul>", items, "</ul></p>"]
  end

  defp socialize(%{socialize_url: nil}), do: nil

  defp socialize(%{socialize_url: url}) do
    {"podcast:socialInteract", %{uri: url, protocol: "activitypub"}}
  end

  defp transcript(episode) do
    if Episode.has_transcript(episode) do
      {"podcast:transcript",
       %{url: url(~p"/#{episode.podcast.slug}/#{episode.slug}/transcript"), type: "text/html"}}
    else
      nil
    end
  end
end
