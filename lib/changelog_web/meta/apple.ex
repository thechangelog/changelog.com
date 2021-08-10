defmodule ChangelogWeb.Meta.Apple do
  alias ChangelogWeb.{EpisodeView, PodcastView}

  # Episode page
  def apple_podcasts_id(%{view_module: EpisodeView, view_template: "show.html", podcast: podcast, episode: _episode}) do
    apple_podcasts_id(%{view_module: PodcastView, podcast: podcast})
  end

  # Podcast pages
  def apple_podcasts_id(%{view_module: PodcastView, podcast: podcast}) do
    if url = podcast.apple_url do
      url
      |> String.split("/")
      |> List.last()
      |> String.replace_leading("id", "")
    end
  end

  def apple_podcasts_id(_), do: nil
end
