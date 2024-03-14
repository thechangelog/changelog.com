defmodule ChangelogWeb.Meta.Twitter do
  use ChangelogWeb, :verified_routes

  alias ChangelogWeb.{AlbumView, EpisodeView, PageView, PodcastView, PostView}

  def get(type, conn) do
    view = Phoenix.Controller.view_module(conn)
    template = Phoenix.Controller.view_template(conn)
    assigns = Map.merge(conn.assigns, %{view_module: view, view_template: template})

    case type do
      :card_type -> card_type(assigns)
      :player_url -> player_url(assigns)
      :audio_url -> audio_url(assigns)
    end
  end

  defp card_type(%{view_module: EpisodeView, view_template: "show.html"}), do: "player"

  defp card_type(%{view_module: AlbumView}), do: "summary_large_image"

  defp card_type(%{view_module: PageView, view_template: "ten.html"}),
    do: "summary_large_image"

  defp card_type(%{view_module: PageView, view_template: "index.html"}),
    do: "summary_large_image"

  defp card_type(%{view_module: PodcastView}), do: "summary_large_image"

  defp card_type(%{view_module: PostView, post: %{image: img}}) when is_map(img),
    do: "summary_large_image"

  defp card_type(_), do: "summary"

  defp player_url(%{
         view_module: EpisodeView,
         view_template: "show.html",
         podcast: podcast,
         episode: episode
       }) do
    url(~p"/#{podcast.slug}/#{episode.slug}/embed?source=twitter")
  end

  defp player_url(_), do: ""

  defp audio_url(%{view_module: EpisodeView, view_template: "show.html", episode: episode}) do
    EpisodeView.audio_url(episode)
  end

  defp audio_url(_), do: ""
end
