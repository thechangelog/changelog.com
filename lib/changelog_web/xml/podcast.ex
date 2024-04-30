defmodule ChangelogWeb.Xml.Podcast do
  use ChangelogWeb, :verified_routes

  alias Changelog.{Episode, ListKit}
  alias ChangelogWeb.{EpisodeView, FeedView, PersonView, PodcastView, TimeView, Xml}
  alias ChangelogWeb.Helpers.SharedHelpers

  @doc """
  Returns a full XML document structure ready to be sent to Xml.generate/1
  """
  def document(podcast, episodes) do
    {
      :rss,
      %{
        version: "2.0",
        "xmlns:atom": "http://www.w3.org/2005/Atom",
        "xmlns:content": "http://purl.org/rss/1.0/modules/content/",
        "xmlns:dc": "http://purl.org/dc/elements/1.1/",
        "xmlns:itunes": "http://www.itunes.com/dtds/podcast-1.0.dtd",
        "xmlns:podcast": "https://podcastindex.org/namespace/1.0",
        "xmlns:psc": "http://podlove.org/simple-chapters"
      },
      [channel(podcast, episodes)]
    }
    |> XmlBuilder.document()
  end

  def channel(podcast, episodes) do
    {
      :channel,
      nil,
      [
        {:title, nil, podcast.name},
        {:copyright, nil, "All rights reserved"},
        {:link, nil, FeedView.podcast_url(podcast)},
        {"atom:link",
         %{href: PodcastView.feed_url(podcast), rel: "self", type: "application/rss+xml"}},
        {"atom:link",
         %{href: FeedView.podcast_url(podcast), rel: "alternate", type: "text/html"}},
        {:language, nil, "en-us"},
        {:description, nil, FeedView.podcast_full_description(podcast)},
        {"itunes:summary", nil, FeedView.podcast_full_description(podcast)},
        {"itunes:explicit", nil, "no"},
        {"itunes:image", %{href: PodcastView.cover_url(podcast)}},
        {"itunes:author", nil, "Changelog Media"},
        {"itunes:owner", nil, itunes_owner()},
        {"itunes:keywords", nil, podcast.keywords},
        {"itunes:category", nil, itunes_category()},
        itunes_sub_category(podcast),
        {"podcast:funding", %{url: "https://changelog.com/++"},
         "Support our work by joining Changelog++"},
        Enum.map(podcast.active_hosts, fn p -> person(p, "host") end),
        Enum.map(episodes, fn episode -> episode(podcast, episode) end)
      ]
      |> List.flatten()
      |> ListKit.compact()
    }
  end

  def episode(podcast, episode) do
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
       {"itunes:explicit", nil, "no"},
       Enum.map(episode.hosts, fn p -> person(p, "host") end),
       Enum.map(episode.guests, fn p -> person(p, "guest") end),
       transcript(episode),
       chapters(episode),
       socialize(episode),
       {"content:encoded", nil, show_notes(episode)}
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

  defp itunes_category() do
    [{"itunes:category", %{text: "Software How-To"}}, {"itunes:category", %{text: "Tech News"}}]
  end

  defp itunes_sub_category(%{slug: "news"}) do
    {"itunes:category", %{text: "News"}, [{"itunes:category", %{text: "Tech News"}}]}
  end

  defp itunes_sub_category(%{slug: "brainscience"}) do
    {"itunes:category", %{text: "Health &amp; Fitness"},
     [{"itunes:category", %{text: "Mental Health"}}]}
  end

  defp itunes_sub_category(%{slug: "founderstalk"}) do
    {"itunes:category", %{text: "Business"},
     [
       {"itunes:category", %{text: "Careers"}},
       {"itunes:category", %{text: "Entrepreneurship"}}
     ]}
  end

  defp itunes_sub_category(_podcast), do: nil

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
