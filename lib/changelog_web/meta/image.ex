defmodule ChangelogWeb.Meta.Image do
  import ChangelogWeb.Router.Helpers, only: [static_url: 2]

  alias ChangelogWeb.{Endpoint, NewsItemView, NewsSourceView, PersonView, TopicView}

  def fb_image(assigns), do: assigns |> get_fb
  def fb_image_width(assigns), do: assigns |> get_fb_width
  def fb_image_height(assigns), do: assigns |> get_fb_height
  def twitter_image(assigns), do: assigns |> get_twitter

  defp get_fb(%{podcast: podcast}), do: static_url(Endpoint, "/images/podcasts/#{podcast.slug}-cover-art.png")
  defp get_fb(_), do: nil
  defp get_fb_width(%{podcast: _podcast}), do: "3000"
  defp get_fb_width(_), do: nil
  defp get_fb_height(%{podcast: _podcast}), do: "3000"
  defp get_fb_height(_), do: nil

  defp get_twitter(%{podcast: podcast}), do: static_url(Endpoint, "/images/podcasts/#{podcast.slug}-cover-art.png")
  defp get_twitter(%{view_module: NewsItemView, item: item}) do
    cond do
      item.author -> PersonView.avatar_url(item.author)
      item.source && item.source.icon -> NewsSourceView.icon_url(item.source)
      topic = Enum.find(item.topics, &(&1.icon)) -> TopicView.icon_url(topic)
      true -> static_url(Endpoint, "/images/defaults/type-#{item.type}.png")
    end
  end
  defp get_twitter(_), do: static_url(Endpoint, "/images/share/sitewide-twitter-summary.png")
end
