defmodule ChangelogWeb.JsonFeedView do
  use ChangelogWeb, :public_view

  alias Changelog.{Episode, Post}
  alias ChangelogWeb.{EpisodeView, NewsItemView,
                      TimeView, Helpers.SharedHelpers}

  def render("news.json", %{conn: conn, items: items}) do
    %{
      "version": "https://jsonfeed.org/version/1",
      "title": "Changelog",
      "home_page_url": root_url(conn, :index),
      "description": "News and podcasts for developers",
      "items": render_many(items, __MODULE__, "news_item.json", %{conn: conn})
    }
  end

  def render("news_item.json", %{conn: conn, json_feed: item = %{object: nil}}) do
    %{
      "title": item.headline |> html_escape |> safe_to_string,
      "url": news_item_url(conn, :show, NewsItemView.slug(item)),
      "date_published": TimeView.to_rfc3339(item.published_at),
      "author": %{
        "name": item.logger.name
      },
      "content_html": SharedHelpers.md_to_html(item.story),
      "content_text": item.story,
    }
  end

  def render("news_item.json", %{conn: conn, json_feed: item = %{object: episode = %Episode{}}}) do
    %{
      "title": episode.podcast.name <> " " <> EpisodeView.numbered_title(episode, "") |> html_escape |> safe_to_string,
      "url": episode_url(conn, :show, episode.podcast.slug, episode.slug),
      "date_published": TimeView.to_rfc3339(episode.published_at),
      "content_html": SharedHelpers.md_to_html(item.story),
      "content_text": item.story,
      "attachments": [
        %{
          "url": EpisodeView.audio_url(episode),
          "mime_type": "audio/mpeg",
          "length": episode.bytes
        }
      ]
    }
  end

  def render("news_item.json", %{conn: conn, json_feed: item = %{object: post = %Post{}}}) do
    %{
      "title": post.title |> html_escape |> safe_to_string,
      "author": %{
        "name": post.author.name
      },
      "url": post_url(conn, :show, post.slug),
      "date_published": TimeView.to_rfc3339(post.published_at),
      "content_html": SharedHelpers.md_to_html(item.story),
      "content_text": item.story
    }
  end
end
