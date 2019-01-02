defmodule ChangelogWeb.NewsItemView do
  use ChangelogWeb, :public_view

  alias Changelog.{Episode, Files, Hashid, NewsAd, NewsItem, Podcast, Regexp, UrlKit}
  alias ChangelogWeb.{Endpoint, NewsAdView, NewsItemCommentView, NewsSourceView,
                      EpisodeView, PersonView, TopicView, PodcastView}

  def admin_edit_link(conn, user, item) do
    if user && user.admin do
      content_tag(:span, class: "news_item-toolbar-meta-item") do
        [
          link("[Edit]", to: admin_news_item_path(conn, :edit, item, next: current_path(conn)), data: [turbolinks: false]),
          content_tag(:span, " (#{item.click_count}/#{item.impression_count})")
        ]
      end
    end
  end

  def comment_count_aside(item) do
    case NewsItem.comment_count(item) do
      0 -> ""
      x -> "(#{x})"
    end
  end

  def discuss_with_count(item) do
    ["discuss", comment_count_aside(item)]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(" ")
  end

  def discussion_path(_conn, item = %{type: :link, object: post}) when is_map(post) do
     dev_relative("#{item.url}#discussion")
  end
  def discussion_path(conn, item = %NewsItem{}) do
    item_path = news_item_path(conn, :show, slug(item))
    if item_path === conn.request_path do
      "#discussion"
    else
      item_path
    end
  end

  def hashid(item), do: Hashid.encode(item.id)

  def image_link(item, version \\ :large) do
    if item.image do
      content_tag :div, class: "news_item-image" do
        link to: item.url do
          tag(:img, src: image_url(item, version), alt: item.headline)
        end
      end
    end
  end

  def image_mime_type(item) do
    Files.Image.mime_type(item.image)
  end

  def image_path(item, version) do
    {item.image, item}
    |> Files.Image.url(version)
    |> String.replace_leading("/priv", "")
  end

  def image_url(item, version) do
    static_url(Endpoint, image_path(item, version))
  end

  def items_with_ads(items, []), do: items
  def items_with_ads(items, ads) do
    items
    |> List.insert_at(3, Enum.at(ads, 0))
    |> List.insert_at(9, Enum.at(ads, 1))
    |> Enum.reject(&is_nil/1)
  end

  def object_path(%{object_id: nil}), do: nil
  def object_path(%{object_id: object_id}), do: "/" <> String.replace(object_id, ":", "/")

  def permalink_path(conn, item) do
    if item.object_id, do: dev_relative(item.url), else: news_item_path(conn, :show, slug(item))
  end

  def permalink_data(item) do
    if item.object_id, do: [news: true], else: []
  end

  def render_item_summary_or_ad(item = %NewsItem{}, assigns), do: render("_summary.html", Map.merge(assigns, %{item: item, style: "relativeShort"}))
  def render_item_summary_or_ad(ad = %NewsAd{}, assigns), do: render(NewsAdView, "_summary.html", Map.merge(assigns, %{ad: ad, sponsor: ad.sponsor}))

  def render_meta_people(conn, item = %{type: :audio, object: episode}) when is_map(episode) do
    render("meta/_featuring.html", conn: conn, item: item, episode: episode)
  end
  def render_meta_people(conn, item) do
    render("meta/_logged_by.html", conn: conn, item: item)
  end

  def render_source_image(conn, item = %{type: :audio, object: episode}) when is_map(episode) do
    render("source/_image_episode.html", conn: conn, item: item, episode: episode)
  end
  def render_source_image(conn, item) do
    cond do
      item.author -> render("source/_image_author.html", conn: conn, item: item, author: item.author)
      item.source && item.source.icon -> render("source/_image_source.html", conn: conn, item: item, source: item.source)
      topic = Enum.find(item.topics, &(&1.icon)) -> render("source/_image_topic.html", conn: conn, item: item, topic: topic)
      true -> render("source/_image_fallback.html", conn: conn, item: item)
    end
  end

  # same as `render_source_image` except the cascade is re-ordered
  def render_source_name(conn, item = %{type: :audio, object: episode}) when is_map(episode) do
    render("source/_name_episode.html", conn: conn, item: item, episode: episode)
  end
  def render_source_name(conn, item) do
    cond do
      item.source && item.source.icon -> render("source/_name_source.html", conn: conn, item: item, source: item.source)
      item.author -> render("source/_name_author.html", conn: conn, item: item, author: item.author)
      true -> render("source/_name_fallback.html", conn: conn, item: item)
    end
  end

  def render_title(conn, item) do
    if item.object_id do
      render("title/_internal.html", conn: conn, item: item)
    else
      render("title/_external.html", conn: conn, item: item)
    end
  end

  def render_toolbar_button(conn, item = %{type: :audio, object: episode}) when is_map(episode) do
    render("toolbar/_button_episode.html", conn: conn, item: item, episode: episode)
  end
  def render_toolbar_button(conn, item = %{type: :video}) do
    if id = UrlKit.get_youtube_id(item.url) do
      render("toolbar/_button_video.html", conn: conn, item: item, id: id)
    end
  end
  def render_toolbar_button(conn, item = %{image: image}) when not is_nil(image) do
    render("toolbar/_button_image.html", conn: conn, item: item)
  end
  def render_toolbar_button(_conn, _item), do: nil

  def render_youtube_embed(nil), do: nil
  def render_youtube_embed(id), do: render("_youtube_embed.html", id: id)

  def slug(item) do
    item.headline
    |> String.downcase
    |> String.replace(~r/[^a-z0-9\s]/, "")
    |> String.trim
    |> String.replace(~r/\s+/, "-")
    |> Kernel.<>("-#{hashid(item)}")
  end

  def teaser(item, max_words \\ 20) do
    item.story
    |> md_to_html
    |> prepare_html
    |> String.split
    |> truncate(word_count(item.story), max_words)
    |> Enum.join(" ")
  end

  def topic_list(item) do
    item.topics
    |> Enum.map(&("##{&1.slug}"))
    |> Enum.join(" ")
  end

  def topic_link(conn, topic) do
    link("##{topic.slug}", to: topic_path(conn, :show, topic.slug), title: "View #{topic.name}")
  end

  def video_embed(item = %{type: :video}) do
    item.url |> UrlKit.get_youtube_id() |> render_youtube_embed()
  end
  def video_embed(_), do: nil

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
    sliced = Enum.slice(html_list, 0..(max_words - 1))
    tags = Regex.scan(Regexp.tag, Enum.join(sliced, " "), capture: ["tag"]) |> List.flatten

    sliced ++ case Integer.mod(length(tags), 2) do
      0 -> ["..."]
      1 -> ["</#{List.last(tags)}>", "..."]
    end
  end
end
