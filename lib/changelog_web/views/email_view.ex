defmodule ChangelogWeb.EmailView do
  use ChangelogWeb, :public_view

  alias Changelog.{Faker, NewsItem}

  alias ChangelogWeb.{
    AuthView,
    Endpoint,
    EpisodeView,
    NewsItemView,
    NewsItemCommentView,
    PersonView
  }

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

  def comment_url(item, comment) do
    news_item_url(item) <> NewsItemCommentView.permalink_path(comment)
  end
end
