defmodule Changelog.Buffer.Content do
  alias Changelog.{Episode, ListKit, NewsItem}
  alias ChangelogWeb.{Endpoint, NewsItemView, Router}

  def episode_link(nil), do: nil
  def episode_link(item), do: item.url

  def episode_text(nil), do: ""
  def episode_text(item) do
    item =
      item
      |> NewsItem.preload_all()
      |> NewsItem.load_object()

    episode = item.object
    people = Episode.participants(episode)

    meta = [
      title_meta(episode),
      featuring_meta(people),
      topic_meta(item.topics)
    ] |> Enum.reject(&is_nil/1)

    if Enum.any?(meta) do
      """
      #{episode_emoji()} New episode of #{episode.podcast.name}!

      #{Enum.join(meta, "\n")}

      💚 #{episode_link(item)}
      """
    else
      """
      #{episode_emoji()} New episode of #{episode.podcast.name}!

      💚 #{episode_link(item)}
      """
    end
  end

  def news_item_image(nil), do: nil
  def news_item_image(%{image: nil}), do: nil
  def news_item_image(item), do: NewsItemView.image_url(item, :original)

  def news_item_link(nil), do: nil
  def news_item_link(item) do
    Router.Helpers.news_item_url(Endpoint, :show, NewsItemView.hashid(item))
  end

  def news_item_text(nil), do: ""
  def news_item_text(item) do
    item = NewsItem.preload_all(item)

    if length(item.topics) >= 2 do
      news_item_verbose_text(item)
    else
      news_item_terse_text(item)
    end
  end

  defp news_item_terse_text(item) do
    [news_item_headline(item), news_item_byline(item), news_item_link(item)]
    |> ListKit.compact_join("\n")
  end

  defp news_item_verbose_text(item) do
    [news_item_headline(item), news_item_meta(item), news_item_link(item)]
    |> ListKit.compact_join("\n\n")
  end

  def post_link(nil), do: nil
  def post_link(item), do: item.url

  def post_text(nil), do: ""
  def post_text(item), do: news_item_text(item)

  defp news_item_headline(item = %{type: :video}), do: "#{video_emoji()} #{item.headline}"
  defp news_item_headline(item), do: item.headline

  defp news_item_byline(%{author: author, source: source}) when is_map(author) and is_map(source) do
    "#{author_emoji()} by #{twitterized(author)} via #{twitterized(source)}"
  end
  defp news_item_byline(%{author: author}) when is_map(author) do
    "#{author_emoji()} by #{twitterized(author)}"
  end
  defp news_item_byline(_item), do: nil

  defp news_item_meta(item) do
    meta = [
      author_meta(item),
      source_meta(item),
      topic_meta(item.topics)
    ] |> Enum.reject(&is_nil/1)

    if Enum.any?(meta) do
      Enum.join(meta, "\n")
    else
      nil
    end
  end

  defp author_emoji,    do: ~w(✍ 🖋 📝 🗣) |> Enum.random()
  defp episode_emoji,   do: ~w(🙌 🎉 📢 🔥 🎧 🎁 💥) |> Enum.random()
  defp featuring_emoji, do: ~w(🌟 🎙 ✨ ⚡️ 💫) |> Enum.random()
  defp source_emoji,    do: ~w(📨 📡 📢 🔊) |> Enum.random()
  defp title_emoji,     do: ~w(🗣 💬) |> Enum.random()
  defp topic_emoji,     do: ~w(🏷 💭 🗂 ) |> Enum.random()
  defp video_emoji,     do: ~w(🎞 📽 🎬 🍿) |> Enum.random()

  defp author_meta(%{author: nil}), do: nil
  defp author_meta(%{author: %{twitter_handle: nil}}), do: nil
  defp author_meta(%{author: %{twitter_handle: handle}}), do: "#{author_emoji()} by @#{handle}"

  defp featuring_meta([]), do: nil
  defp featuring_meta(people), do: "#{featuring_emoji()} #{twitter_list(people, ", ")}"

  defp source_meta(%{source: nil}), do: nil
  defp source_meta(%{source: %{twitter_handle: nil}}), do: nil
  defp source_meta(%{source: %{twitter_handle: handle}}), do: "#{source_emoji()} via @#{handle}"

  defp title_meta(episode), do: "#{title_emoji()} #{episode.title}"

  defp topic_meta([]), do: nil
  defp topic_meta(topics) do
    "#{topic_emoji()} #{twitter_list(topics)}"
  end

  defp twitter_list(list, delimiter \\ " ") when is_list(list) do
    list
    |> Enum.map(&twitterized/1)
    |> Enum.join(delimiter)
  end

  defp twitterized(%{slug: "go"}), do: "#golang"
  defp twitterized(%{twitter_handle: nil, slug: slug}) when is_binary(slug), do: "#" <> String.replace(slug, "-", "")
  defp twitterized(%{twitter_handle: handle}) when is_binary(handle), do: "@" <> handle
  defp twitterized(%{name: name}), do: name
end
