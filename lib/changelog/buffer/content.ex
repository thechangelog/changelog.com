defmodule Changelog.Buffer.Content do
  alias Changelog.NewsItem
  alias ChangelogWeb.{Endpoint, Helpers, NewsItemView, Router}

  def news_item_image(nil), do: nil
  def news_item_image(%{image: nil}), do: nil
  def news_item_image(item), do: NewsItemView.image_url(item, :original)

  def news_item_link(nil), do: nil
  def news_item_link(item) do
    if Helpers.SharedHelpers.word_count(item.story) < 20 do
      item.url
    else
      Router.Helpers.news_item_url(Endpoint, :show, NewsItemView.hashid(item))
    end
  end

  def news_item_text(nil), do: ""
  def news_item_text(item) do
    item = NewsItem.preload_all(item)

    text = if Enum.any?(item.topics) do
      Enum.reduce(item.topics, item.headline, &(insert_topic_reference(&2, &1)))
    else
      item.headline
    end

    text = if item.source && item.source.twitter_handle do
      "#{text} (via @#{item.source.twitter_handle})"
    else
      text
    end

    text
  end

  defp insert_topic_reference(text, topic) do
    if String.match?(text, ~r/#{topic.name}/) do
      String.replace(text, topic.name, twitterized(topic, :name))
    else
      text <> " #{twitterized(topic, :slug)}"
    end
  end

  defp twitterized(topic, attr) do
    if topic.twitter_handle do
      "@" <> topic.twitter_handle
    else
      "#" <> String.replace(Map.get(topic, attr), ~r/[\s-]/, "")
    end
  end
end
