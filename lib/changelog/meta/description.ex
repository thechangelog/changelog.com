defmodule Changelog.Meta.Description do
  alias Changelog.{EpisodeView, PodcastView}

  def description(assigns), do: assigns |> get

  defp get(%{view_module: EpisodeView, episode: episode}) do
    Changelog.Helpers.ViewHelpers.md_to_text(episode.summary)
  end

  defp get(%{view_module: PodcastView, podcast: podcast}) do
    podcast.description
  end

  defp get(_), do: "Podcasts, News, and Films by/for developers. Hacker to the heart."
end
