defmodule ChangelogWeb.PodcastView do
  use ChangelogWeb, :public_view

  alias Changelog.{Podcast, StringKit}
  alias ChangelogWeb.{Endpoint, EpisodeView, NewsItemView, PersonView, SharedView}
  alias Changelog.Files.Cover

  def cover_path(%{slug: "master"}, version), do: "/images/podcasts/master-#{version}.png"
  def cover_path(%{slug: "plusplus"}, version), do: "/images/podcasts/plusplus-#{version}.png"

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
      |> List.first()

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
      Routes.static_url(Endpoint, cover_path(podcast, version))
    else
      "/images/defaults/black.png"
    end
  end

  def dasherized_name(%{name: name}), do: StringKit.dasherize(name)

  def is_master(podcast), do: Podcast.is_master(podcast)
  def episode_count(podcast), do: Podcast.episode_count(podcast)
  def published_episode_count(podcast), do: Podcast.published_episode_count(podcast)

  def subscribe_on_android_url(%{vanity_domain: vanity}) when not is_nil(vanity),
    do: vanity <> "/android"

  def subscribe_on_android_url(podcast) do
    feed_url_sans_protocol =
      Routes.feed_url(Endpoint, :podcast, podcast.slug)
      |> String.replace(~r/\Ahttps?:\/\//, "")

    "https://www.subscribeonandroid.com/#{feed_url_sans_protocol}"
  end

  def subscribe_on_apple_url(%{vanity_domain: vanity}) when not is_nil(vanity),
    do: vanity <> "/apple"

  def subscribe_on_apple_url(podcast), do: podcast.apple_url

  def subscribe_on_overcast_url(%{vanity_domain: vanity}) when not is_nil(vanity),
    do: vanity <> "/overcast"

  def subscribe_on_overcast_url(podcast) do
    %{"id" => id, "name" => name} =
      Regex.named_captures(~r/\/podcast\/(?<name>.*)\/id(?<id>.*)/, podcast.apple_url)

    "https://overcast.fm/itunes#{id}/#{name}"
  end

  def subscribe_on_spotify_url(%{vanity_domain: vanity}) when not is_nil(vanity),
    do: vanity <> "/spotify"

  def subscribe_on_spotify_url(podcast), do: podcast.spotify_url

  def subscribe_via_email_path(conn, podcast) do
    if conn.assigns.current_user do
      Routes.home_path(conn, :show) <> "#podcasts"
    else
      Routes.person_path(conn, :subscribe, podcast.slug)
    end
  end

  def subscribe_via_rss_url(_conn, %{vanity_domain: vanity}) when not is_nil(vanity),
    do: vanity <> "/rss"

  def subscribe_via_rss_url(conn, podcast), do: Routes.feed_path(conn, :podcast, podcast.slug)

  def status_text(podcast) do
    if podcast.status == :soon do
      "coming soon"
    else
      podcast.status
    end
  end
end
