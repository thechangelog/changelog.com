defmodule ChangelogWeb.PodcastView do
  use ChangelogWeb, :public_view

  alias Changelog.Podcast
  alias ChangelogWeb.{Endpoint, EpisodeView, PersonView, TimeView, SharedView}

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

  def is_master(podcast), do: Podcast.is_master(podcast)
  def episode_count(podcast), do: Podcast.episode_count(podcast)
  def published_episode_count(podcast), do: Podcast.published_episode_count(podcast)

  def subscribe_link(podcast) do
    page_path(Endpoint, :subscribe) <> "##{podcast.slug}"
  end

  def subscribe_on_android_url(podcast) do
    feed_url_sans_protocol =
      feed_url(Endpoint, :podcast, podcast.slug)
      |> String.replace(~r/\Ahttps?:\/\//, "")
    "http://www.subscribeonandroid.com/#{feed_url_sans_protocol}"
  end

  def subscribe_on_overcast_url(podcast) do
    %{"id" => id, "name" => name} = Regex.named_captures(~r/\/podcast\/(?<name>.*)\/id(?<id>.*)/, podcast.itunes_url)
    "https://overcast.fm/itunes#{id}/#{name}"
  end

  def vanity_domain_with_fallback_url(podcast) do
    if podcast.vanity_domain do
      podcast.vanity_domain
    else
      podcast_url(Endpoint, :show, podcast.slug)
    end
  end
end
