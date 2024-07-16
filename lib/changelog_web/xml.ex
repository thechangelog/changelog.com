defmodule ChangelogWeb.Xml do
  use ChangelogWeb, :verified_routes

  alias Changelog.Episode
  alias ChangelogWeb.{PersonView}

  def generate(document), do: XmlBuilder.generate(document)

  def itunes_category() do
    [{"itunes:category", %{text: "Software How-To"}}, {"itunes:category", %{text: "Tech News"}}]
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
