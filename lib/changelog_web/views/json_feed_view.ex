defmodule ChangelogWeb.JsonFeedView do
  use ChangelogWeb, :public_view

  import ChangelogWeb.Helpers.SharedHelpers, only: [md_to_html: 1, md_to_text: 1]

  alias Changelog.{Episode, Post}
  alias ChangelogWeb.{EpisodeView, NewsItemView, TimeView}

  def render("news.json", %{conn: conn, items: items}) do
    %{
      version: "https://jsonfeed.org/version/1",
      title: "Changelog",
      home_page_url: root_url(conn, :index),
      feed_url: json_feed_url(conn, :news),
      description: "News and podcasts for developers",
      items: render_many(items, __MODULE__, "news_item.json", %{conn: conn})
    }
  end

  def render("news_item.json", %{conn: conn, json_feed: item = %{object: nil}}) do
    json = %{
      id: news_item_url(conn, :show, NewsItemView.hashid(item)),
      title: item.headline |> html_escape |> safe_to_string,
      url: item.url,
      date_published: TimeView.rfc3339(item.published_at),
      author: %{name: item.logger.name},
      content_html: md_to_html(item.story),
      content_text: md_to_text(item.story),
    }

    if item.image do
      Map.put(json, :attachments, [image_attachment(item)])
    else
      json
    end
  end

  def render("news_item.json", %{conn: conn, json_feed: item = %{object: episode = %Episode{}}}) do
    %{
      id: news_item_url(conn, :show, NewsItemView.hashid(item)),
      title: episode.podcast.name <> " " <> EpisodeView.numbered_title(episode, "") |> html_escape |> safe_to_string,
      url: episode_url(conn, :show, episode.podcast.slug, episode.slug),
      date_published: TimeView.rfc3339(episode.published_at),
      content_html: md_to_html(item.story),
      content_text: md_to_text(item.story),
      attachments: [audio_attachment(episode)]
    }
  end

  def render("news_item.json", %{conn: conn, json_feed: item = %{object: post = %Post{}}}) do
    %{
      id: news_item_url(conn, :show, NewsItemView.hashid(item)),
      title: post.title |> html_escape |> safe_to_string,
      author: %{name: post.author.name},
      url: post_url(conn, :show, post.slug),
      date_published: TimeView.rfc3339(post.published_at),
      content_html: md_to_html(item.story),
      content_text: md_to_text(item.story)
    }
  end

  defp audio_attachment(episode) do
    %{
      url: EpisodeView.audio_url(episode),
      mime_type: "audio/mpeg",
      size_in_bytes: episode.bytes,
      duration_in_seconds: episode.duration
    }
  end

  defp image_attachment(item) do
    %{
      url: NewsItemView.image_url(item, :large),
      mime_type: NewsItemView.image_mime_type(item)
    }
  end
end
