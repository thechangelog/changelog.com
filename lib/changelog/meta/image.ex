defmodule Changelog.Meta.Image do
  def fb_image(assigns), do: assigns |> get_fb
  def twitter_image(assigns), do: assigns |> get_twitter

  defp get_fb(%{podcast: podcast}), do: "/images/share/#{podcast.slug}-fb.jpg"
  defp get_fb(_), do: "/images/share/sitewide-fb.jpg"

  defp get_twitter(%{podcast: podcast}), do: "/images/share/#{podcast.slug}-twitter.jpg"
  defp get_twitter(_), do: "/images/share/sitewide-twitter.jpg"
end
