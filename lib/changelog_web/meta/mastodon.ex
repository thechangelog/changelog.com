defmodule ChangelogWeb.Meta.Mastodon do
  alias ChangelogWeb.{EpisodeView, Helpers, Meta, PodcastView}

  def get(conn) do
    conn |> Meta.prep_assigns() |> mastodon()
  end

  # Episode page
  defp mastodon(%{
         view_module: EpisodeView,
         view_template: "show.html",
         podcast: podcast,
         episode: _episode
       }) do
    mastodon(%{view_module: PodcastView, podcast: podcast})
  end

  # Podcast page
  defp mastodon(%{view_module: PodcastView, podcast: podcast}) do
    Helpers.SharedHelpers.mastodon_url(podcast)
  end

  defp mastodon(_), do: nil
end
