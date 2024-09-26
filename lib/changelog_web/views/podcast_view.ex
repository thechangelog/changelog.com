defmodule ChangelogWeb.PodcastView do
  use ChangelogWeb, :public_view

  alias Changelog.{Podcast, StringKit, UrlKit}
  alias ChangelogWeb.{EpisodeView, PersonView, SharedView}
  alias Changelog.Files.Cover

  def active_podcasts_for_index(podcasts) do
    pods =
      podcasts
      |> Enum.reject(&Podcast.is_a_changelog_pod/1)
      |> Enum.filter(&Podcast.is_active/1)

    List.flatten([Podcast.changelog(), pods, Podcast.master(), Podcast.plusplus()])
  end

  def inactive_podcasts_for_index(podcasts) do
    Enum.reject(podcasts, &Podcast.is_active/1)
  end

  def apple_id(podcast) do
    if url = podcast.apple_url do
      url
      |> String.split("/")
      |> List.last()
      |> String.replace_leading("id", "")
    end
  end

  def color_hex_code(podcast) do
    case podcast.slug do
      "brainscience" ->
        "F9423A"

      "founderstalk" ->
        "5FC4B4"

      "gotime" ->
        "58CAF5"

      "jsparty" ->
        "FDCF0F"

      "practicalai" ->
        "4A5FAA"

      "shipit" ->
        "97CC69"

      _else ->
        "59B287"
    end
  end

  def cover_url(podcast, version \\ :original)

  # Special cases for Master, The Changelog & ++
  def cover_url(%{slug: "master"}, version) do
    image = "master-#{version}.png"
    url(~p"/images/podcasts/#{image}")
  end

  def cover_url(%{slug: "podcast", is_meta: true}, version) do
    image = "podcast-#{version}.png"
    url(~p"/images/podcasts/#{image}")
  end

  def cover_url(%{slug: "plusplus"}, version) do
    image = "plusplus-#{version}.png"
    url(~p"/images/podcasts/#{image}")
  end

  # Standard case
  def cover_url(podcast, version) do
    if podcast.cover do
      Cover.url({podcast.cover, podcast}, version)
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
    slug = Podcast.slug_with_interviews_special_case(podcast)
    url(~p"/#{slug}/feed")
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
    %{"id" => id, "name" => name} = apple_url_parts(podcast)

    "https://overcast.fm/itunes#{id}/#{name}"
  end

  def subscribe_on_pocket_casts_url(%{vanity_domain: vanity}) when not is_nil(vanity),
    do: vanity <> "/pcast"

  def subscribe_on_pocket_casts_url(podcast) do
    %{"id" => id, "name" => _name} = apple_url_parts(podcast)

    "https://pca.st/itunes/#{id}"
  end

  defp apple_url_parts(podcast) do
    Regex.named_captures(~r/\/podcast\/(?<name>.*)\/id(?<id>.*)/, podcast.apple_url)
  end

  def subscribe_on_spotify_url(%{vanity_domain: vanity}) when not is_nil(vanity),
    do: vanity <> "/spotify"

  def subscribe_on_spotify_url(podcast), do: podcast.spotify_url

  def subscribe_on_youtube_url(%{vanity_domain: vanity}) when not is_nil(vanity),
    do: vanity <> "/youtube"

  def subscribe_on_youtube_url(podcast), do: podcast.youtube_url

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
