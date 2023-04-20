defmodule ChangelogWeb.Meta.Apple do
  alias ChangelogWeb.{EpisodeView, Meta, PodcastView}

  def get(type, conn) do
    assigns = Meta.prep_assigns(conn)

    case type do
      :podcasts_id -> podcasts_id(assigns)
    end
  end

  # Episode page
  defp podcasts_id(%{
        view_module: EpisodeView,
        view_template: "show.html",
        podcast: podcast,
        episode: _episode
      }) do
    podcasts_id(%{view_module: PodcastView, podcast: podcast})
  end

  # Podcast pages
  defp podcasts_id(%{view_module: PodcastView, podcast: podcast}) do
    PodcastView.apple_id(podcast)
  end

  defp podcasts_id(_), do: nil
end
