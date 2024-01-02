defmodule ChangelogWeb.PodcastView do
  use ChangelogWeb, :public_view

  alias Changelog.{Podcast, StringKit, UrlKit}
  alias ChangelogWeb.{Endpoint, EpisodeView, PersonView, SharedView}
  alias Changelog.Files.Cover

  def podcasts_for_index(podcasts) do
    pods = Enum.reject(podcasts, &Podcast.is_a_changelog_pod/1)

    List.flatten([Podcast.changelog, pods, Podcast.master])
  end

  def apple_id(podcast) do
    if url = podcast.apple_url do
      url
      |> String.split("/")
      |> List.last()
      |> String.replace_leading("id", "")
    end
  end

  def cover_path(%{slug: "master"}, version) do
    image = "master-#{version}.png"
    url(~p"/images/podcasts/#{image}")
  end

  def cover_path(%{slug: "podcast", is_meta: true}, version) do
    image = "podcast-#{version}.png"
    url(~p"/images/podcasts/#{image}")
  end

  def cover_path(%{slug: "plusplus"}, version) do
    image = "plusplus-#{version}.png"
    url(~p"/images/podcasts/#{image}")
  end

  def cover_path(podcast, version), do: Cover.url({podcast.cover, podcast}, version)

  def cover_url(podcast), do: cover_url(podcast, :original)

  def cover_url(podcast, version) do
    if podcast.cover do
      cover_path(podcast, version)
    else
      url(~p"/images/defaults/black.png")
    end
  end

  # Any time (except cover art) we're dealing with Interviews, we want it to
  # be represented by the old "The Changelog" name
  def dasherized_name(%{name: "Changelog Interviews"}), do: "the-changelog"
  def dasherized_name(%{name: name}), do: StringKit.dasherize(name)

  def is_master(podcast), do: Podcast.is_master(podcast)
  def episode_count(podcast), do: Podcast.episode_count(podcast)

  # Exists to special-case /interviews
  def feed_url(podcast) do
    slug = if Podcast.is_interviews(podcast), do: "interviews", else: podcast.slug
    Routes.feed_url(Endpoint, :podcast, slug)
  end

  def published_episode_count(podcast), do: Podcast.published_episode_count(podcast)

  def subscribe_on_android_url(%{vanity_domain: vanity}) when not is_nil(vanity),
    do: vanity <> "/android"

  def subscribe_on_android_url(podcast) do
    path = podcast |> feed_url() |> UrlKit.sans_scheme()

    "https://www.subscribeonandroid.com/#{path}"
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

  def subscribe_via_rss_url(%{vanity_domain: vanity}) when not is_nil(vanity),
    do: vanity <> "/rss"

  def subscribe_via_rss_url(podcast), do: feed_url(podcast)

  def status_text(podcast) do
    if podcast.status == :soon do
      "coming soon"
    else
      podcast.status
    end
  end
end
