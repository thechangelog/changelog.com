defmodule Changelog.Meta.Description do
  alias Changelog.{EpisodeView, PodcastView, PostView}

  import Changelog.Helpers.ViewHelpers, only: [md_to_text: 1]

  def description(assigns), do: assigns |> get

  defp get(%{view_module: EpisodeView, episode: episode}) do
    md_to_text(episode.summary)
  end

  defp get(%{view_module: PodcastView, podcast: podcast}) do
    podcast.description
  end

  defp get(%{view_module: PostView, post: post}) do
    if post.tldr do
      md_to_text(post.tldr)
    else
      post.title
    end
  end

  defp get(_), do: "Podcasts, News, and Films by/for developers. Hacker to the heart."
end
