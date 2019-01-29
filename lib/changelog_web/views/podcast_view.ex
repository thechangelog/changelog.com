defmodule ChangelogWeb.PodcastView do
  use ChangelogWeb, :public_view

  alias Changelog.{Podcast, StringKit}
  alias ChangelogWeb.{Endpoint, NewsItemView, PersonView, SharedView}
  alias Changelog.Files.Cover

  def cover_path(%{slug: "master"}, version), do: "/images/podcasts/master-#{version}.png"
  def cover_path(podcast, version) do
    {podcast.cover, podcast}
    |> Cover.url(version)
    |> String.replace_leading("/priv", "")
  end

  def cover_local_path(podcast) do
    path =
      podcast
      |> cover_path(:original)
      |> String.split("?")
      |> List.first

    arc_dir = Application.get_env(:arc, :storage_dir)

    if String.starts_with?(path, arc_dir) do
      path
    else
      Application.app_dir(:changelog, "priv#{path}")
    end
  end

  def cover_url(podcast), do: cover_url(podcast, :original)
  def cover_url(podcast, version) do
    if podcast.cover do
      static_url(Endpoint, cover_path(podcast, version))
    else
      "/images/defaults/black.png"
    end
  end

  def dasherized_name(podcast), do: StringKit.dasherize(podcast.name)

  def is_master(podcast), do: Podcast.is_master(podcast)
  def episode_count(podcast), do: Podcast.episode_count(podcast)
  def published_episode_count(podcast), do: Podcast.published_episode_count(podcast)

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

  def status_text(podcast) do
    if podcast.status == :soon do
      "coming soon"
    else
      podcast.status
    end
  end
end
