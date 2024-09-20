defmodule ChangelogWeb.EmailView do
  use ChangelogWeb, :public_view

  alias Changelog.{Faker, HtmlKit, NewsItem, Podcast, UrlKit}

  alias ChangelogWeb.{
    AuthView,
    Endpoint,
    EpisodeView,
    NewsItemView,
    NewsItemCommentView,
    PersonView,
    PodcastView
  }

  def feed_app_url(feed, app_prefix, strip_scheme \\ true) do
    feed_url = url(~p"/feeds/#{feed.slug}")

    if strip_scheme do
      app_prefix <> UrlKit.sans_scheme(feed_url)
    else
      app_prefix <> feed_url
    end
  end

  def greeting(nil), do: "Hey there,"

  def greeting(person) do
    label =
      if Faker.name_fake?(person.name) do
        "there"
      else
        PersonView.first_name(person)
      end

    "Hey #{label},"
  end

  def news_item_promotion_advice(item) do
    case item.type do
      :project -> ~s{Add "Featured on Changelog News" to the README and/or homepage}
      :announcement -> ~s{Add "Discuss this on Changelog News" to the end of your announcement}
      _else -> ~s{Add "Discuss this on Changelog News" to the end of your article}
    end
  end

  def news_item_url(%{type: :link, object: post}) when is_map(post) do
    Routes.post_url(Endpoint, :show, post.slug)
  end

  def news_item_url(item) do
    Routes.news_item_url(Endpoint, :show, NewsItem.slug(item))
  end

  def news_title(episode) do
    title = "Changelog News ##{episode.slug}"

    if episode.published_at do
      "#{title} (#{TimeView.hacker_date(episode.published_at)})"
    else
      title
    end
  end

  def comment_url(item, comment) do
    news_item_url(item) <> NewsItemCommentView.permalink_path(comment)
  end

  def admin_news_item_comment_url(comment) do
    Routes.admin_news_item_comment_url(Endpoint, :edit, comment.id)
  end
end
