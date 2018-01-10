defmodule ChangelogWeb.NewsItemView do
  use ChangelogWeb, :public_view

  alias Changelog.{Episode, Files, Hashid, NewsAd, NewsItem, Regexp, Repo}
  alias ChangelogWeb.{NewsSourceView, EpisodeView, PersonView, TopicView}

  def admin_edit_link(conn, user, item) do
    if user && user.admin do
      link("[Edit]", to: admin_news_item_path(conn, :edit, item), data: [turbolinks: false])
    end
  end

  def get_object(item) do
    case item.type do
      :audio -> get_episode_object(item.object_id)
      _else -> nil
    end
  end

  defp get_episode_object(object_id) when is_nil(object_id), do: nil
  defp get_episode_object(object_id) do
    [p, e] = String.split(object_id, ":")
    Episode.published
    |> Episode.with_podcast_slug(p)
    |> Episode.with_slug(e)
    |> Episode.preload_all
    |> Repo.one
  end

  def image_url(item, version) do
    Files.Image.url({item.image, item}, version)
    |> String.replace_leading("/priv", "")
  end

  def render_item_or_ad(item = %NewsItem{}), do: render("_item.html", item: item)
  def render_item_or_ad(ad = %NewsAd{}), do: render("_ad.html", ad: ad)

  def render_item_header_source(conn, item = %{type: :audio}) do
    if episode = get_object(item) do
      render("_item_header_episode.html", conn: conn, item: item, episode: episode)
    else
      render_item_header_source(conn, Map.put(item, :type, :link))
    end
  end
  def render_item_header_source(conn, item) do
    cond do
      item.source -> render("_item_header_source.html", conn: conn, item: item, source: item.source)
      item.author -> render("_item_header_author.html", conn: conn, item: item, author: item.author)
      Enum.any?(item.topics) -> render("_item_header_topic.html", conn: conn, item: item, topic: List.first(item.topics))
      true -> render("_item_header_default.html", conn: conn, item: item)
    end
  end

  def slug(item) do
    item.headline
    |> String.downcase
    |> String.replace(~r/[^a-z0-9\s]/, "")
    |> String.replace(~r/\s+/, "-")
    |> Kernel.<>("-#{Hashid.encode(item.id)}")
  end

  def teaser(story, max_words \\ 20) do
    word_count = story |> md_to_text |> String.split |> length

    story
    |> md_to_html
    |> prepare_html
    |> String.split
    |> truncate(word_count, max_words)
    |> Enum.join(" ")
  end

  def topic_link_list(conn, item) do
    item.topics
    |> Enum.map(fn(topic) ->
      {:safe, el} = link("\##{topic.slug}", to: topic_path(conn, :show, topic.slug), title: "View #{topic.name}")
      el
      end)
    |> Enum.join(" ")
  end

  defp prepare_html(html) do
    html
    |> String.replace("\n", " ") # treat news lines as spaces
    |> String.replace(Regexp.tag("p"), "") # remove p tags
    |> String.replace(~r/(<\w+>)\s+(\S)/, "\\1\\2" ) # attach open tags to next word
    |> String.replace(~r/(\S)\s+(<\/\w+>)/, "\\1\\2" ) # attach close tags to prev word
    |> String.replace(Regexp.tag("blockquote"), "\\1i\\2") # treat as italics
  end

  defp truncate(html_list, total_words, max_words) when total_words <= max_words, do: html_list
  defp truncate(html_list, _total_words, max_words) do
    sliced = Enum.slice(html_list, 0..(max_words-1))
    tags = Regex.scan(Regexp.tag, Enum.join(sliced, " "), capture: ["tag"]) |> List.flatten

    sliced ++ case Integer.mod(length(tags), 2) do
      0 -> ["..."]
      1 -> ["</#{List.last(tags)}>", "..."]
    end
  end
end
