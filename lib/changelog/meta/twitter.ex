defmodule Changelog.Meta.Twitter do
  alias Changelog.{EpisodeView, PageView, PodcastView}

  def twitter_card_type(assigns), do: assigns |> get

  defp get(%{view_module: EpisodeView}), do: "summary_large_image"
  defp get(%{view_module: PodcastView}), do: "summary_large_image"
  defp get(%{view_module: PageView, view_template: "home.html"}), do: "summary_large_image"
  defp get(_), do: "summary"
end
