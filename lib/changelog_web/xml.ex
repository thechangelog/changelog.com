defmodule ChangelogWeb.Xml do
  use ChangelogWeb, :verified_routes

  alias Changelog.{Episode, ListKit}
  alias ChangelogWeb.{EpisodeView, FeedView, PersonView}
  alias ChangelogWeb.Helpers.SharedHelpers

  def generate(document), do: XmlBuilder.generate(document)

  def itunes_category do
    [{"itunes:category", %{text: "Technology"}}]
  end

  def itunes_sub_category(%{slug: "news"}) do
    {"itunes:category", %{text: "News"}, [{"itunes:category", %{text: "Tech News"}}]}
  end

  def itunes_sub_category(%{slug: "brainscience"}) do
    {"itunes:category", %{text: "Health &amp; Fitness"},
     [{"itunes:category", %{text: "Mental Health"}}]}
  end

  def itunes_sub_category(%{slug: "founderstalk"}) do
    {"itunes:category", %{text: "Business"},
     [
       {"itunes:category", %{text: "Careers"}},
       {"itunes:category", %{text: "Entrepreneurship"}}
     ]}
  end

  def itunes_sub_category(_podcast), do: nil

  def itunes_owner do
    [{"itunes:name", nil, "Changelog Media"}, {"itunes:email", nil, "editors@changelog.com"}]
  end

  def person(person, role) do
    {"podcast:person",
     %{
       role: role,
       img: PersonView.avatar_url(person, :large),
       href: PersonView.profile_url(person)
     }, person.name}
  end

  def podcast_namespaces do
    %{
      version: "2.0",
      "xmlns:atom": "http://www.w3.org/2005/Atom",
      "xmlns:content": "http://purl.org/rss/1.0/modules/content/",
      "xmlns:itunes": "http://www.itunes.com/dtds/podcast-1.0.dtd",
      "xmlns:podcast": "https://podcastindex.org/namespace/1.0",
      "xmlns:psc": "http://podlove.org/simple-chapters"
    }
  end

  def posts_namespaces do
    %{
      version: "2.0",
      "xmlns:dc": "http://purl.org/dc/elements/1.1/"
    }
  end

  def show_notes(episode, plusplus \\ false) do
    data =
      [
        SharedHelpers.md_to_html(episode.summary),
        show_notes_newsletter_link(episode),
        FeedView.discussion_link(episode),
        show_notes_plusplus_cta(episode, plusplus),
        show_notes_sponsors(episode, plusplus),
        show_notes_featuring(episode),
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

  defp show_notes_plusplus_cta(_episode, true), do: nil

  defp show_notes_plusplus_cta(episode, false) do
    ~s(<p><a href="#{url(~p"/++")}" rel="payment">Changelog++</a> #{EpisodeView.plusplus_cta(episode)} Join today!</p>)
  end

  # However, News episodes do not have additional notes
  defp show_notes_notes(%{podcast: %{slug: "news"}}), do: nil

  defp show_notes_notes(episode) do
    [
      "<p>Show Notes:</p>",
      "<p>#{SharedHelpers.md_to_html(episode.notes)}</p>",
      ~s(<p>Something missing or broken? <a href="#{EpisodeView.show_notes_source_url(episode)}">PRs welcome!</a></p>)
    ] |> Enum.join("")
  end

  defp show_notes_sponsors(_episode, true), do: nil

  defp show_notes_sponsors(%{episode_sponsors: []}, false), do: nil

  defp show_notes_sponsors(%{episode_sponsors: sponsors}, false) do
    items =
      Enum.map(sponsors, fn s ->
        description = s.description |> SharedHelpers.md_to_html() |> SharedHelpers.sans_p_tags()

        ~s"""
        <li><a href="#{s.link_url}">#{s.title}</a> – #{description}</li>
        """
      end)

    ["<p>Sponsors:</p><p><ul>", items, "</ul></p>"]
  end

  defp show_notes_featuring(episode) do
    case EpisodeView.participants(episode) do
      [] -> nil
      participants ->
        items =
          Enum.map(participants, fn p ->
            ~s(<li>#{p.name} &ndash; #{PersonView.list_of_links(p)}</li>)
          end)

        ["<p>Featuring:</p><ul>", items, "</ul></p>"]
    end
  end

  def socialize(%{socialize_url: nil}), do: nil

  def socialize(%{socialize_url: url}) do
    {"podcast:socialInteract", %{uri: url, protocol: "activitypub"}}
  end

  def transcript(episode) do
    if Episode.has_transcript(episode) do
      {"podcast:transcript",
       %{url: url(~p"/#{episode.podcast.slug}/#{episode.slug}/transcript"), type: "text/html"}}
    else
      nil
    end
  end
end
