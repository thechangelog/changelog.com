defmodule ChangelogWeb.JsonFeedViewTest do
  use ChangelogWeb.ConnCase, async: true

  alias Changelog.NewsItem
  alias ChangelogWeb.{NewsItemView, TimeView, EpisodeView, Helpers.SharedHelpers}

  import ChangelogWeb.JsonFeedView

  setup_all do
    {:ok, endpoint: ChangelogWeb.Endpoint}
  end

  describe "render" do
    test "news.json is the header of the JSON feed", %{endpoint: endpoint} do
      header = render("news.json", %{conn: endpoint, items: []})

      assert header == %{
        :version => "https://jsonfeed.org/version/1",
        :title => "Changelog",
        :home_page_url => "http://localhost:4001/",
        :description => "News and podcasts for developers",
        :items => []
      }
    end

    test "news_item.json map a NewsItem to a JSON feed item", %{endpoint: endpoint} do
      news_item =
        insert(:published_news_item, story: "**a story**")
        |> NewsItem.load_object

      json = render("news_item.json", %{conn: endpoint, json_feed: news_item})

      assert json == %{
        :title => news_item.headline,
        :url => news_item_url(endpoint, :show, NewsItemView.slug(news_item)),
        :date_published => TimeView.rfc3339(news_item.published_at),
        :author => %{
          :name => news_item.logger.name
        },
        :content_html => SharedHelpers.md_to_html(news_item.story),
        :content_text => SharedHelpers.md_to_text(news_item.story),
      }
    end

    test "news_item.json map a NewsItem with an Episode to a JSON feed item", %{endpoint: endpoint} do
      episode = insert(:published_episode, summary: "zomg")

      news_item = episode
        |> episode_news_item_with_story("**a story**")
        |> insert
        |> NewsItem.load_object

      json = render("news_item.json", %{conn: endpoint, json_feed: news_item})

      assert json == %{
        :title => "#{episode.podcast.name} #{episode.title}",
        :url => episode_url(endpoint, :show, episode.podcast.slug, episode.slug),
        :date_published => TimeView.rfc3339(episode.published_at),
        :content_html => SharedHelpers.md_to_html(news_item.story),
        :content_text => SharedHelpers.md_to_text(news_item.story),
        :attachments => [
          %{
            :url => EpisodeView.audio_url(episode),
            :mime_type => "audio/mpeg",
            :length => episode.bytes
          }
        ]
      }
    end

    test "news_item.json map a NewsItem with a Post to a JSON feed item", %{endpoint: endpoint} do
      post = insert(:published_post, body: "zomg")

      news_item = post
        |> post_news_item_with_story("**a story**")
        |> NewsItem.load_object

      json = render("news_item.json", %{conn: endpoint, json_feed: news_item})

      assert json == %{
        :title => post.title,
        :author => %{
          :name => post.author.name
        },
        :url => post_url(endpoint, :show, post.slug),
        :date_published => TimeView.rfc3339(post.published_at),
        :content_html => SharedHelpers.md_to_html(news_item.story),
        :content_text => SharedHelpers.md_to_text(news_item.story)
      }
    end
  end
end
