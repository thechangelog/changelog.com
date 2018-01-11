defmodule ChangelogWeb.NewsItemView do
  use ChangelogWeb, :public_view

  alias Changelog.{Files, Hashid, NewsAd, NewsItem, Regexp}
  alias ChangelogWeb.{NewsSourceView, EpisodeView, PersonView, SponsorView, TopicView}

  def admin_edit_link(conn, user, item) do
    if user && user.admin do
      link("[Edit]", to: admin_news_item_path(conn, :edit, item), data: [turbolinks: false])
    end
  end

  def image_url(item, version) do
    Files.Image.url({item.image, item}, version)
    |> String.replace_leading("/priv", "")
  end

  def items_with_ads(items, []), do: items
  def items_with_ads(items, ads) do
    items
    |> Enum.chunk_every(4)
    |> Enum.with_index
    |> Enum.map(fn{items, index} ->
      case Enum.at(ads, index) do
        nil -> items
        ad -> items ++ [ad]
      end
    end)
    |> List.flatten
  end

  def render_item_summary_or_ad(item = %NewsItem{}, assigns), do: render("_item_summary.html", Map.merge(assigns, %{item: item}))
  def render_item_summary_or_ad(ad = %NewsAd{}, assigns), do: render("_ad_summary.html", Map.merge(assigns, %{ad: ad}))

  def render_item_source(conn, item = %{type: :audio}) do
    if item.object do
      render("_item_source_episode.html", conn: conn, item: item, episode: item.object)
    else
      render_item_source(conn, Map.put(item, :type, :link))
    end
  end
  def render_item_source(conn, item) do
    cond do
      item.source -> render("_item_source_source.html", conn: conn, item: item, source: item.source)
      item.author -> render("_item_source_author.html", conn: conn, item: item, author: item.author)
      Enum.any?(item.topics) -> render("_item_source_topic.html", conn: conn, item: item, topic: List.first(item.topics))
      true -> render("_item_source_default.html", conn: conn, item: item)
    end
  end

  def render_item_title(conn, item) do
    if item.object_id do
      render("_item_title_internal.html", conn: conn, item: item)
    else
      render("_item_title_external.html", conn: conn, item: item)
    end
  end

  def render_item_toolbar_button(conn, item = %{type: :audio}) do
    if item.object do
      render("_item_toolbar_button_episode.html", conn: conn, item: item, episode: item.object)
    else
      render_item_toolbar_button(conn, Map.put(item, :type, :link))
    end
  end
  def render_item_toolbar_button(_conn, _item), do: ""

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
