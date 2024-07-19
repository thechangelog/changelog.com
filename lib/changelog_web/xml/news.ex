defmodule ChangelogWeb.Xml.News do
  use ChangelogWeb, :verified_routes

  alias Changelog.{Episode, ListKit, Post}
  alias ChangelogWeb.Xml

  @doc """
  Returns a full XML document structure ready to be sent to Xml.generate/1
  """
  def document(news_items) do
    {
      :rss,
      Map.merge(Xml.podcast_namespaces(), Xml.posts_namespaces()),
      [channel(news_items)]
    }
    |> XmlBuilder.document()
  end

  def channel(news_items) do
    {
      :channel,
      nil,
      [
        {:title, nil, "Changelog"},
        {:copyright, nil, "All rights reserved"},
        {:link, nil, url(~p"/")},
        {"atom:link", %{href: url(~p"/feed"), rel: "self", type: "application/rss+xml"}},
        {"atom:link", %{href: url(~p"/"), rel: "alternate", type: "text/html"}},
        {:language, nil, "en-us"},
        {:description, nil, "News and podcasts for developers"},
        Enum.map(news_items, fn news_item -> item(news_item) end)
      ]
      |> List.flatten()
      |> ListKit.compact()
    }
  end

  def item(%{object: episode = %Episode{}}) do
    episode = episode |> Episode.preload_all()
    Xml.Podcast.item(episode.podcast, episode)
  end

  def item(%{object: post = %Post{}}) do
    Xml.Posts.item(post)
  end

  # we only render Episode and Post items now
  def item(_other), do: nil
end
