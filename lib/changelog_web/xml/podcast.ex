defmodule ChangelogWeb.Xml.Podcast do
  use ChangelogWeb, :verified_routes

  alias Changelog.{ListKit}
  alias ChangelogWeb.{EpisodeView, FeedView, PersonView, PodcastView, TimeView, Xml}
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
        {"itunes:explicit", nil, "no"},
        {"itunes:image", %{href: PodcastView.cover_url(podcast)}},
        {"itunes:author", nil, "Changelog Media"},
        {"itunes:owner", nil, Xml.itunes_owner()},
        {"itunes:keywords", nil, podcast.keywords},
        {"itunes:category", nil, Xml.itunes_category()},
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
       {"itunes:explicit", nil, "no"},
       Enum.map(episode.hosts, fn p -> Xml.person(p, "host") end),
       Enum.map(episode.guests, fn p -> Xml.person(p, "guest") end),
       Xml.transcript(episode),
       chapters(episode),
       Xml.socialize(episode),
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

  defp show_notes(episode) do
    sponsors = episode.episode_sponsors
    participants = EpisodeView.participants(episode)

    data =
      [
        SharedHelpers.md_to_html(episode.summary),
        show_notes_newsletter_link(episode),
        FeedView.discussion_link(episode),
        ~s(<p><a href="#{url(~p"/++")}" rel="payment">Changelog++</a> #{EpisodeView.plusplus_cta(episode)} Join today!</p>),
        show_notes_sponsors(sponsors),
        show_notes_featuring(participants),
        show_notes_notes(episode)
      ]
      |> ListKit.compact_join("")

    {:cdata, data}
  end

  # Only News episodes have a newsletter link for now
  defp show_notes_newsletter_link(%{slug: slug, podcast: %{slug: "news"}}) do
    ~s(<p><a href="#{url(~p"/news/#{slug}/email")}">View the newsletter</a></p>)
  end

  defp show_notes_newsletter_link(_other), do: nil

  # However, News episodes do not have additional notes
  defp show_notes_notes(%{podcast: %{slug: "news"}}), do: nil

  defp show_notes_notes(episode) do
    [
      "<p>Show Notes:</p>",
      "<p>#{SharedHelpers.md_to_html(episode.notes)}</p>",
      ~s(<p>Something missing or broken? <a href="#{EpisodeView.show_notes_source_url(episode)}">PRs welcome!</a></p>)
    ] |> Enum.join("")
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
end
