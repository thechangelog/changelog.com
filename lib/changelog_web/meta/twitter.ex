defmodule ChangelogWeb.Meta.Twitter do
  alias ChangelogWeb.{Endpoint, EpisodeView, PageView, PodcastView, PostView, Router.Helpers}

  def twitter_card_type(%{view_module: EpisodeView, view_template: "show.html"}), do: "player"

  def twitter_card_type(%{view_module: PageView, view_template: "ten.html"}),
    do: "summary_large_image"

  def twitter_card_type(%{view_module: PodcastView}), do: "summary_large_image"

  def twitter_card_type(%{view_module: PostView, post: %{image: img}}) when is_map(img),
    do: "summary_large_image"

  def twitter_card_type(_), do: "summary"

  def twitter_player_url(%{
        view_module: EpisodeView,
        view_template: "show.html",
        podcast: podcast,
        episode: episode
      }) do
    Helpers.episode_url(Endpoint, :embed, podcast.slug, episode.slug, source: "twitter")
  end

  def twitter_player_url(_), do: ""

  def twitter_audio_url(%{view_module: EpisodeView, view_template: "show.html", episode: episode}) do
    EpisodeView.audio_url(episode)
  end

  def twitter_audio_url(_), do: ""
end
