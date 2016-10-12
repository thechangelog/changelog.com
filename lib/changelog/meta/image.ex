defmodule Changelog.Meta.Image do
  alias Changelog.{PageView}

  def fb_image(assigns), do: assigns |> get_fb
  def twitter_image(assigns), do: assigns |> get_twitter

  defp get_fb(%{podcast: podcast}), do: "/images/share/#{podcast.slug}-fb.png"
  defp get_fb(_), do: "/images/share/sitewide-fb.png"

  defp get_twitter(%{podcast: podcast}), do: "/images/share/#{podcast.slug}-twitter.png"
  defp get_twitter(%{view_module: PageView, view_template: "home.html"}), do: "/images/share/sitewide-twitter-large.png"
  defp get_twitter(_), do: "/images/share/sitewide-twitter-summary.png"
end
