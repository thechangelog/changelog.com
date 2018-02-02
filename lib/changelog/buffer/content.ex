defmodule Changelog.Buffer.Content do
  alias Changelog.NewsItem
  alias ChangelogWeb.{Endpoint, Helpers, NewsItemView, Router}

  def news_item_text(nil), do: ""
  def news_item_text(item) do
    item = NewsItem.preload_all(item)

    [
      item.headline,
      news_item_link(item),
      news_item_source_and_topics(item)
    ]
    |> Enum.reject(&(&1 == ""))
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n\n")
  end

  def news_item_image(nil), do: nil
  def news_item_image(%{image: nil}), do: nil
  def news_item_image(item), do: NewsItemView.image_url(item, :original)

  def news_item_link(nil), do: nil
  def news_item_link(item) do
    if Helpers.SharedHelpers.word_count(item.story) < 20 do
      item.url
    else
      Router.Helpers.news_item_url(Endpoint, :show, NewsItemView.slug(item))
    end
  end

  defp news_item_source_and_topics(item) do
    if item.source && item.source.twitter_handle do
      "via @#{item.source.twitter_handle} #{NewsItemView.topic_list(item)}"
    else
      NewsItemView.topic_list(item)
    end
  end
end
