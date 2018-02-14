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

    meta = [
      author_meta(item),
      source_meta(item),
      topic_meta(item.topics),
    ] |> Enum.reject(&is_nil/1)

    if Enum.any?(meta) do
      """
      #{item.headline}

      #{Enum.join(meta, "\n")}

      #{news_item_link(item)}
      """
    else
      """
      #{item.headline}

      #{news_item_link(item)}
      """
    end
  end

  defp author_emoji, do: Enum.random(~w(✍ 🖋 📝))
  defp source_emoji, do: Enum.random(~w(📨 📡 📯))
  defp topic_emoji, do: Enum.random(~w(🏷 🔎))

  defp author_meta(%{author: nil}), do: nil
  defp author_meta(%{author: %{twitter_handle: nil}}), do: nil
  defp author_meta(%{author: %{twitter_handle: handle}}), do: "#{author_emoji()} by @#{handle}"

  defp source_meta(%{source: nil}), do: nil
  defp source_meta(%{source: %{twitter_handle: nil}}), do: nil
  defp source_meta(%{source: %{twitter_handle: handle}}), do: "#{source_emoji()} via @#{handle}"

  defp topic_meta([]), do: nil
  defp topic_meta(topics) do
    list =
      topics
      |> Enum.map(&twitterized/1)
      |> Enum.join(" ")

    "#{topic_emoji()} on #{list}"
  end

  defp twitterized(%{twitter_handle: nil, slug: slug}), do: "#" <> String.replace(slug, "-", "")
  defp twitterized(%{twitter_handle: handle}), do: "@" <> handle
end
