defmodule ChangelogWeb.Meta.Image do
  alias ChangelogWeb.Router.Helpers, as: Routes

  alias ChangelogWeb.{
    Endpoint,
    Meta,
    NewsItemView,
    NewsSourceView,
    PageView,
    PersonView,
    PodcastView,
    PostView,
    TopicView
  }

  def get(type, conn) do
    assigns = Meta.prep_assigns(conn)

    case type do
      :fb_image -> fb_image(assigns)
      :fb_image_width -> fb_image_width(assigns)
      :fb_image_height -> fb_image_height(assigns)
      :twitter_image -> twitter_image(assigns)
    end
  end

  # a specific podcast
  defp fb_image(%{podcast: podcast}), do: podcast_image(podcast)

  # the podcasts index
  defp fb_image(%{view_module: PodcastView, view_template: "index.html"}), do: podcasts_image()

  # # a specific news item with an image
  defp fb_image(%{view_module: NewsItemView, item: item = %{image: img}}) when is_map(img),
    do: NewsItemView.image_url(item, :original)

  defp fb_image(%{view_module: PageView, view_template: "ten.html"}),
    do: static_image("/images/content/ten/ten-year-social.jpg")

  # a specific post
  defp fb_image(%{view_module: PostView, post: post}) do
    cond do
      post.image -> post_image(post)
      true -> fb_summary_image()
    end
  end

  defp fb_image(_), do: fb_summary_image()

  defp fb_image_width(%{podcast: _podcast}), do: "3000"
  defp fb_image_width(%{view_module: NewsItemView, item: %{image: img}}) when is_map(img), do: nil
  defp fb_image_width(_), do: "1200"

  defp fb_image_height(%{podcast: _podcast}), do: "1688"
  defp fb_image_height(%{view_module: NewsItemView, item: %{image: img}}) when is_map(img), do: nil
  defp fb_image_height(_), do: "630"

  defp twitter_image(%{view_module: PageView, view_template: "ten.html"}),
    do: static_image("/images/content/ten/ten-year-social.jpg")

  # a specific podcast
  defp twitter_image(%{podcast: podcast}), do: podcast_image(podcast)

  # the podcasts index
  defp twitter_image(%{view_module: PodcastView, view_template: "index.html"}), do: podcasts_image()

  # a specific post
  defp twitter_image(%{view_module: PostView, post: post}) do
    cond do
      post.image -> post_image(post)
      post.author -> person_image(post.author)
      true -> twitter_summary_image()
    end
  end

  # a specific news item
  defp twitter_image(%{view_module: NewsItemView, item: item}) do
    cond do
      item.author -> person_image(item.author)
      item.source && item.source.icon -> source_image(item.source)
      topic = Enum.find(item.topics, & &1.icon) -> topic_image(topic)
      true -> item_type_image(item)
    end
  end

  # a specific news source
  defp twitter_image(%{view_module: NewsSourceView, source: source}), do: source_image(source)

  # a specific person's profile
  defp twitter_image(%{view_module: PersonView, person: person}) when is_map(person),
    do: person_image(person)

  # a specific topic
  defp twitter_image(%{view_module: TopicView, topic: topic}), do: topic_image(topic)

  # everything else
  defp twitter_image(_), do: twitter_summary_image()

  defp item_type_image(item), do: static_image("/images/defaults/type-#{item.type}.png")
  defp person_image(person), do: PersonView.avatar_url(person, :large)
  defp podcast_image(podcast), do: static_image("/images/share/twitter-#{podcast.slug}.png")
  defp podcasts_image, do: static_image("/images/share/all-podcasts.png")
  defp post_image(post), do: PostView.image_url(post, :large)
  defp source_image(source), do: NewsSourceView.icon_url(source, :large)
  defp static_image(path), do: Routes.static_url(Endpoint, path)
  defp topic_image(topic), do: TopicView.icon_url(topic, :large)

  defp fb_summary_image, do: static_image("/images/share/fb-sitewide.png")
  defp twitter_summary_image, do: static_image("/images/share/twitter-sitewide-summary.png")
end
