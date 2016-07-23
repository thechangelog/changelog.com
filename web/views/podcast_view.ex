defmodule Changelog.PodcastView do
  use Changelog.Web, :view

  def cover_art_path(podcast, extension \\ "svg") do
    "/images/podcasts/#{podcast.slug}-cover-art.#{extension}"
  end

  def cover_art_local_path(podcast, extension \\ "svg") do
    url = cover_art_path(podcast, extension)
    Application.app_dir(:changelog, "priv/static#{url}")
  end

  def dasherized_name(podcast) do
    podcast.name
    |> String.downcase
    |> String.replace(~r/[^\w\s]/, "")
    |> String.replace(" ", "-")
  end

  def episode_count(podcast) do
    Changelog.Podcast.episode_count(podcast)
  end

  def published_episode_count(podcast) do
    Changelog.Podcast.published_episode_count(podcast)
  end

  def vanity_domain_with_fallback_url(podcast) do
    if podcast.vanity_domain do
      podcast.vanity_domain
    else
      podcast_url(Changelog.Endpoint, :show, podcast.slug)
    end
  end
end
