defmodule ChangelogWeb.NewsItemView do
  use ChangelogWeb, :public_view

  alias Changelog.{Episode, Files, NewsAd, NewsItem, Podcast, Regexp, Subscription, UrlKit}

  alias ChangelogWeb.{
    Endpoint,
    NewsAdView,
    NewsItemCommentView,
    NewsSourceView,
    EpisodeView,
    PersonView,
    TopicView,
    PodcastView
  }

  def admin_edit_link(conn, %{admin: true}, item = %{type: :audio, object: episode})
      when is_map(episode) do
    content_tag(:span, class: "news_item-toolbar-meta-item") do
      [
        link("[#{item.click_count}/#{item.impression_count}]",
          to:
            Routes.admin_podcast_episode_path(conn, :edit, episode.podcast.slug, episode.slug,
              next: SharedHelpers.current_path(conn)
            )
        )
      ]
    end
  end

  def admin_edit_link(conn, %{admin: true}, item = %{type: :link, object: post})
      when is_map(post) do
    content_tag(:span, class: "news_item-toolbar-meta-item") do
      [
        link("[#{item.click_count}/#{item.impression_count}]",
          to: Routes.admin_post_path(conn, :edit, post, next: SharedHelpers.current_path(conn))
        )
      ]
    end
  end

  def admin_edit_link(conn, %{admin: true}, item) do
    content_tag(:span, class: "news_item-toolbar-meta-item") do
      [
        link("[#{item.click_count}/#{item.impression_count}]",
          to:
            Routes.admin_news_item_path(conn, :edit, item, next: SharedHelpers.current_path(conn))
        )
      ]
    end
  end

  def admin_edit_link(_, _, _), do: nil

  def comment_count_aside(item) do
    case NewsItem.comment_count(item) do
      0 -> ""
      x -> "(#{x})"
    end
  end

  def discuss_with_count(item) do
    ["Discuss", comment_count_aside(item)]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(" ")
  end

  def discussion_path(_conn, item = %{type: :link, object: post}) when is_map(post) do
    SharedHelpers.dev_relative("#{item.url}#discussion")
  end

  def discussion_path(conn, item = %NewsItem{}) do
    item_path = Routes.news_item_path(conn, :show, NewsItem.slug(item))

    if item_path === conn.request_path do
      "#discussion"
    else
      item_path
    end
  end

  def hashid(item), do: NewsItem.hashid(item)

  def image_link(item, version \\ :large) do
    if item.image do
      content_tag :div, class: "news_item-image" do
        link to: news_item_url(item), data: [news: true] do
          tag(:img, src: image_url(item, version), alt: item.headline, loading: "lazy")
        end
      end
    end
  end

  def image_mime_type(item) do
    Files.Image.mime_type(item.image)
  end

  def image_url(item, version), do: Files.Image.url({item.image, item}, version)

  def items_with_ads(items, []), do: items

  def items_with_ads(items, ads) do
    items
    |> List.insert_at(3, Enum.at(ads, 0))
    |> List.insert_at(9, Enum.at(ads, 1))
    |> Enum.reject(&is_nil/1)
  end

  def object_path(%{object_id: nil}), do: nil

  def object_path(item = %{type: :audio}) do
    object = NewsItem.load_object(item).object
    Routes.episode_path(Endpoint, :show, object.podcast.slug, object.slug)
  end

  def object_path(%{object_id: object_id}), do: "/" <> String.replace(object_id, ":", "/")

  def permalink_path(conn, item) do
    if item.object_id,
      do: SharedHelpers.dev_relative(item.url),
      else: Routes.news_item_path(conn, :show, NewsItem.slug(item))
  end

  def permalink_data(item) do
    if item.object_id, do: [news: true], else: []
  end

  def render_footer(conn, item = %{type: :audio, object: episode}) when is_map(episode) do
    render("footer/_episode.html", conn: conn, item: item, episode: episode)
  end

  def render_footer(conn, item = %{type: :link, object: post}) when is_map(post) do
    render("footer/_post.html", conn: conn, item: item, post: post)
  end

  def render_footer(conn, item) do
    render("footer/_item.html", conn: conn, item: item)
  end

  def render_item_summary_or_ad(item = %NewsItem{}, assigns),
    do: render("_summary.html", Map.merge(assigns, %{item: item, style: "relativeShort"}))

  def render_item_summary_or_ad(ad = %NewsAd{}, assigns),
    do:
      render(
        NewsAdView,
        "_summary.html",
        Map.merge(assigns, %{ad: ad, sponsor: ad.sponsorship.sponsor})
      )

  def render_meta_people(conn, item = %{type: :audio, object: episode}) when is_map(episode) do
    render("meta/_featuring.html", conn: conn, item: item, episode: episode)
  end

  def render_meta_people(conn, item = %{type: :link, object: post}) when is_map(post) do
    render("meta/_by.html", conn: conn, item: item, post: post)
  end

  def render_meta_people(conn, item) do
    render("meta/_logged_by.html", conn: conn, item: item)
  end

  def render_source_image(conn, item = %{type: :audio, object: episode}) when is_map(episode) do
    render("source/_image_episode.html", conn: conn, item: item, episode: episode)
  end

  def render_source_image(conn, item) do
    cond do
      item.author && item.author.avatar ->
        render("source/_image_author.html", conn: conn, item: item, author: item.author)

      item.source && item.source.publication && item.source.icon ->
        render("source/_image_source.html", conn: conn, item: item, source: item.source)

      topic = Enum.find(item.topics, & &1.icon) ->
        render("source/_image_topic.html", conn: conn, item: item, topic: topic)

      true ->
        render("source/_image_fallback.html", conn: conn, item: item)
    end
  end

  # same as `render_source_image` except the cascade is re-ordered
  def render_source_name(conn, item = %{type: :audio, object: episode}) when is_map(episode) do
    render("source/_name_episode.html", conn: conn, item: item, episode: episode)
  end

  def render_source_name(conn, item = %{type: :link, object: post}) when is_map(post) do
    render("source/_name_post.html", conn: conn, item: item, post: post)
  end

  def render_source_name(conn, item) do
    cond do
      item.source && item.source.icon ->
        render("source/_name_source.html", conn: conn, item: item, source: item.source)

      item.author ->
        render("source/_name_author.html", conn: conn, item: item, author: item.author)

      true ->
        render("source/_name_fallback.html", conn: conn, item: item)
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

  def render_toolbar_button(_conn, _item), do: nil

  def render_youtube_embed(nil), do: nil
  def render_youtube_embed(id), do: render("_youtube_embed.html", id: id)

  def share_path(conn, item) do
    Routes.news_item_path(conn, :show, hashid(item))
  end

  def teaser(item, max_words \\ 20) do
    item.story
    |> SharedHelpers.md_to_html()
    |> prepare_html
    |> String.split()
    |> truncate(SharedHelpers.word_count(item.story), max_words)
    |> Enum.join(" ")
  end

  def topic_list(item) do
    item.topics
    |> Enum.map(&"##{&1.slug}")
    |> Enum.join(" ")
  end

  def topic_link(conn, topic) do
    link("##{topic.slug}",
      to: Routes.topic_path(conn, :show, topic.slug),
      title: "View #{topic.name}"
    )
  end

  def news_item_url(%{url: url, source: %{slug: "medium"}}), do: UrlKit.via_scribe(url)
  def news_item_url(%{url: url}), do: url

  def video_embed(item = %{type: :video}) do
    item.url |> UrlKit.get_youtube_id() |> render_youtube_embed()
  end

  def video_embed(_), do: nil

  defp prepare_html(html) do
    html
    # treat news lines as spaces
    |> String.replace("\n", " ")
    # remove p tags
    |> String.replace(Regexp.tag("p"), "")
    # attach open tags to next word
    |> String.replace(~r/(<\w+>)\s+(\S)/, "\\1\\2")
    # attach close tags to prev word
    |> String.replace(~r/(\S)\s+(<\/\w+>)/, "\\1\\2")
    # treat as italics
    |> String.replace(Regexp.tag("blockquote"), "\\1i\\2")
  end

  defp truncate(html_list, total_words, max_words) when total_words <= max_words, do: html_list

  defp truncate(html_list, _total_words, max_words) do
    sliced = Enum.slice(html_list, 0..(max_words - 1))
    tags = Regex.scan(Regexp.tag(), Enum.join(sliced, " "), capture: ["tag"]) |> List.flatten()

    sliced ++
      case Integer.mod(length(tags), 2) do
        0 -> ["..."]
        1 -> ["</#{List.last(tags)}>", "..."]
      end
  end
end
