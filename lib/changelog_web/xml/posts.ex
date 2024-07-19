defmodule ChangelogWeb.Xml.Posts do
  use ChangelogWeb, :verified_routes

  alias Changelog.ListKit
  alias ChangelogWeb.{PostView, TimeView, Xml}
  alias ChangelogWeb.Helpers.SharedHelpers

  @doc """
  Returns a full XML document structure ready to be sent to Xml.generate/1
  """
  def document(posts) do
    {
      :rss,
      Xml.posts_namespaces(),
      [channel(posts)]
    }
    |> XmlBuilder.document()
  end

  def channel(posts) do
    {
      :channel,
      nil,
      [
        {:title, nil, "Changelog"},
        {:copyright, nil, "All rights reserved"},
        {:link, nil, url(~p"/posts")},
        {:language, nil, "en-us"},
        {:description, nil, "Changelog Posts"},
        Enum.map(posts, fn post -> item(post) end)
      ]
      |> List.flatten()
      |> ListKit.compact()
    }
  end

  def item(post) do
    {:item, nil,
     [
       {:title, nil, post.title},
       {"dc:creator", nil, post.author.name},
       {:guid, %{isPermaLink: false}, PostView.guid(post)},
       {:link, nil, url(~p"/posts/#{post.slug}")},
       {:pubDate, nil, TimeView.rss(post.published_at)},
       {:description, nil, {:cdata, SharedHelpers.md_to_html(post.body)}}
     ]}
  end
end
