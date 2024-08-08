defmodule Changelog.Buffer.Content do
  use ChangelogWeb, :verified_routes

  alias Changelog.{Episode, ListKit, NewsItem}
  alias ChangelogWeb.{EpisodeView, NewsItemView}

  def episode_link(nil), do: nil
  def episode_link(item), do: item.url

  def episode_text(nil), do: ""

  def episode_text(item) do
    item =
      item
      |> NewsItem.preload_all()
      |> NewsItem.load_object()

    episode =
      item.object
      |> Episode.preload_all()

    meta =
      [
        title_meta(episode),
        guest_meta(episode.guests),
        host_meta(episode.hosts)
      ]
      |> Enum.reject(&is_nil/1)

    emoj = episode_emoji()
    ann = podcast_announcement(episode)

    if Enum.any?(meta) do
      """
      #{emoj} #{ann}

      #{Enum.join(meta, "\n")}

      🎧 #{EpisodeView.share_url(episode)}
      """
    else
      """
      #{emoj} #{ann}

      🎧 #{EpisodeView.share_url(episode)}
      """
    end
  end

  defp podcast_announcement(%{podcast: %{slug: "podcast"}}) do
    "New Changelog interview!"
  end

  defp podcast_announcement(%{podcast: %{slug: "shipit"}}) do
    "New episode of Ship It!"
  end

  defp podcast_announcement(%{podcast: %{name: name}}) do
    "New episode of #{name}!"
  end

  def news_item_brief(nil), do: ""

  def news_item_brief(item) do
    item = NewsItem.preload_all(item)

    [news_item_headline(item), twitter_list(item.topics)]
    |> ListKit.compact_join(" ")
  end

  def news_item_image(nil), do: nil
  def news_item_image(%{image: nil}), do: nil
  def news_item_image(item), do: NewsItemView.image_url(item, :original)

  def news_item_link(nil), do: nil

  def news_item_link(item) do
    url(~p"/news/#{NewsItemView.hashid(item)}")
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
    text =
      [
        news_item_headline(item),
        news_item_byline(item)
      ]
      |> ListKit.compact_join(" ")

    [text, news_item_link(item)]
    |> ListKit.compact_join("\n\n")
  end

  defp news_item_verbose_text(item) do
    [news_item_headline(item), news_item_meta(item), news_item_link(item)]
    |> ListKit.compact_join("\n\n")
  end

  def post_brief(item), do: news_item_brief(item)

  def post_link(nil), do: nil
  def post_link(item), do: item.url

  def post_text(nil), do: ""
  def post_text(item), do: news_item_text(item)

  defp news_item_headline(item = %{type: :video}), do: "#{video_emoji()} #{item.headline}"
  defp news_item_headline(item), do: item.headline

  defp news_item_byline(%{author: author, source: source})
       when is_map(author) and is_map(source) do
    "#{author_emoji()} by #{twitterized(author)} via #{twitterized(source)}"
  end

  defp news_item_byline(%{author: author}) when is_map(author) do
    "#{author_emoji()} by #{twitterized(author)}"
  end

  defp news_item_byline(_item), do: nil

  defp news_item_meta(item) do
    meta =
      [
        author_meta(item),
        source_meta(item),
        topic_meta(item.topics)
      ]
      |> ListKit.compact()

    if Enum.any?(meta) do
      Enum.join(meta, "\n")
    else
      nil
    end
  end

  defp author_emoji, do: ~w(✍ 🖋 📝 🗣) |> Enum.random()
  defp episode_emoji, do: ~w(🙌 🎉 🔥 💥 🚢 🚀 🥳 🤘) |> Enum.random()
  defp guest_emoji, do: ~w(🌟 ✨ 💫 🤩 😎 ) |> Enum.random()
  defp host_emoji, do: ~w(🎙 ⚡️ 🎤 🫡) |> Enum.random()
  defp source_emoji, do: ~w(📨 📡 📢 🔊) |> Enum.random()
  defp title_emoji, do: ~w(🗣 💬 💡 💚 📌) |> Enum.random()
  defp topic_emoji, do: ~w(🏷 🗂 🗃️ 🗄️) |> Enum.random()
  defp video_emoji, do: ~w(🎞 📽 🎬 🍿) |> Enum.random()

  defp author_meta(%{author: nil}), do: nil
  defp author_meta(%{author: %{twitter_handle: nil}}), do: nil
  defp author_meta(%{author: %{twitter_handle: handle}}), do: "#{author_emoji()} by @#{handle}"

  defp guest_intro([_guest]), do: "featuring"
  defp guest_intro(_guests), do: "with"

  defp guest_meta([]), do: nil

  defp guest_meta(guests) do
    [
      guest_emoji(),
      guest_intro(guests),
      twitter_list(guests, " & ")
    ]
    |> ListKit.compact_join()
  end

  defp host_intro([_host]), do: ["hosted by", "host"] |> Enum.random()
  defp host_intro(_hosts), do: ["hosted by", "hosts"] |> Enum.random()

  defp host_meta([]), do: nil

  defp host_meta(hosts) do
    [
      host_emoji(),
      host_intro(hosts),
      twitter_list(hosts, " & ")
    ]
    |> ListKit.compact_join()
  end

  defp source_meta(%{source: nil}), do: nil
  defp source_meta(%{source: %{twitter_handle: nil}}), do: nil
  defp source_meta(%{source: %{twitter_handle: handle}}), do: "#{source_emoji()} via @#{handle}"

  defp title_meta(episode), do: "#{title_emoji()} #{episode.title}"

  defp topic_meta([]), do: nil

  defp topic_meta(topics) do
    [
      topic_emoji(),
      topic_intro(topics),
      twitter_list(topics)
    ]
    |> ListKit.compact_join()
  end

  defp topic_intro(_topics), do: [nil, "tagged"] |> Enum.random()

  # returns a string of twitterized items. If final_delimiter is specified,
  # the last two items will use it instead of typical space delimiter,
  # e.g. @jerodsanto & @adamstac
  defp twitter_list(list, final_delimiter \\ " ") do
    {first, last_two} =
      list
      |> Enum.map(&twitterized/1)
      |> Enum.split(-2)

    [Enum.join(first, " "), Enum.join(last_two, final_delimiter)]
    |> ListKit.compact()
    |> Enum.join(" ")
  end

  defp twitterized(%{slug: "go"}), do: "#golang"

  defp twitterized(%{twitter_handle: nil, slug: slug}) when is_binary(slug),
    do: "#" <> String.replace(slug, "-", "")

  defp twitterized(%{twitter_handle: handle}) when is_binary(handle), do: "@" <> handle
  defp twitterized(%{name: name}), do: name
end
