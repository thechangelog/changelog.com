defmodule ChangelogWeb.Meta.Image do
  import ChangelogWeb.Router.Helpers, only: [static_url: 2]

  alias ChangelogWeb.{Endpoint, NewsItemView, NewsSourceView, PersonView, PodcastView, TopicView, HomeView}

  def fb_image(assigns), do: assigns |> get_fb
  def fb_image_width(assigns), do: assigns |> get_fb_width
  def fb_image_height(assigns), do: assigns |> get_fb_height
  def twitter_image(assigns), do: assigns |> get_twitter

  defp get_fb(%{podcast: podcast}), do: podcast_image(podcast)
  defp get_fb(_), do: nil
  defp get_fb_width(%{podcast: _podcast}), do: "3000"
  defp get_fb_width(_), do: nil
  defp get_fb_height(%{podcast: _podcast}), do: "3000"
  defp get_fb_height(_), do: nil

  defp get_twitter(%{podcast: podcast}), do: podcast_image(podcast)
  defp get_twitter(%{view_module: NewsItemView, item: item}) do
    cond do
      item.author -> person_image(item.author)
      item.source && item.source.icon -> source_image(item.source)
      topic = Enum.find(item.topics, &(&1.icon)) -> topic_image(topic)
      true -> item_type_image(item)
    end
  end
  defp get_twitter(%{view_module: NewsSourceView, source: source}), do: source_image(source)
  defp get_twitter(%{view_module: TopicView, topic: topic}), do: topic_image(topic)
  defp get_twitter(_), do: static_image("/images/share/sitewide-twitter-summary.png")

  defp item_type_image(item), do: static_image("/images/defaults/type-#{item.type}.png")
  defp person_image(person), do: PersonView.avatar_url(person, :large)
  defp podcast_image(podcast), do: PodcastView.cover_url(podcast)
  defp static_image(path), do: static_url(Endpoint, path)
  defp source_image(source), do: NewsSourceView.icon_url(source, :large)
  defp topic_image(topic), do: TopicView.icon_url(topic, :large)
end
