defmodule ChangelogWeb.Meta.Image do
  import ChangelogWeb.Router.Helpers, only: [static_url: 2]
  alias ChangelogWeb.Router.Helpers, as: Routes

  alias ChangelogWeb.{Endpoint, NewsItemView, NewsSourceView, PageView,
                      PersonView, PodcastView, PostView, TopicView}

  def fb_image(assigns), do: assigns |> get_fb()

  def fb_image_width(assigns), do: assigns |> get_fb_width()

  def fb_image_height(assigns), do: assigns |> get_fb_height()

  def twitter_image(assigns), do: assigns |> get_twitter()

  defp get_fb(%{podcast: podcast}), do: podcast_image(podcast)
  defp get_fb(%{view_module: NewsItemView, item: item = %{image: img}}) when is_map(img), do: NewsItemView.image_url(item, :original)
  defp get_fb(%{view_module: PageView, view_template: "ten.html"}), do: static_image("/images/content/ten/ten-year-social.jpg")
  defp get_fb(%{view_module: PostView, post: post}) do
    cond do
      post.image -> post_image(post)
      true -> fb_summary_image()
    end
  end
  defp get_fb(_), do: fb_summary_image()

  defp get_fb_width(%{podcast: _podcast}), do: "3000"
  defp get_fb_width(%{view_module: NewsItemView, item: %{image: img}}) when is_map(img), do: nil
  defp get_fb_width(_), do: "1200"

  defp get_fb_height(%{podcast: _podcast}), do: "1688"
  defp get_fb_height(%{view_module: NewsItemView, item: %{image: img}}) when is_map(img), do: nil
  defp get_fb_height(_), do: "630"

  defp get_twitter(%{view_module: PageView, view_template: "ten.html"}), do: static_image("/images/content/ten/ten-year-social.jpg")
  defp get_twitter(%{view_module: PodcastView, view_template: "index.html"}), do: podcasts_image()
  defp get_twitter(%{podcast: podcast}), do: podcast_image(podcast)
  defp get_twitter(%{view_module: PostView, post: post}) do
    cond do
      post.image -> post_image(post)
      post.author -> person_image(post.author)
      true -> twitter_summary_image()
    end
  end
  defp get_twitter(%{view_module: NewsItemView, item: item}) do
    cond do
      item.author -> person_image(item.author)
      item.source && item.source.icon -> source_image(item.source)
      topic = Enum.find(item.topics, &(&1.icon)) -> topic_image(topic)
      true -> item_type_image(item)
    end
  end
  defp get_twitter(%{view_module: NewsSourceView, source: source}), do: source_image(source)
  defp get_twitter(%{view_module: PersonView, person: person}) when is_map(person), do: person_image(person)
  defp get_twitter(%{view_module: TopicView, topic: topic}), do: topic_image(topic)
  defp get_twitter(_), do: twitter_summary_image()

  defp item_type_image(item), do: static_image("/images/defaults/type-#{item.type}.png")
  defp person_image(person), do: PersonView.avatar_url(person, :large)
  defp podcast_image(podcast), do: static_image("/images/share/twitter-#{podcast.slug}.png")
  defp podcasts_image, do: static_image("/images/share/twitter-all-podcasts.png")
  defp post_image(post), do: PostView.image_url(post, :large)
  defp source_image(source), do: NewsSourceView.icon_url(source, :large)
  defp static_image(path), do: Routes.static_url(Endpoint, path)
  defp topic_image(topic), do: TopicView.icon_url(topic, :large)

  defp fb_summary_image, do: static_image("/images/share/fb-sitewide.png")
  defp twitter_summary_image, do: static_image("/images/share/twitter-sitewide-summary.png")
end
