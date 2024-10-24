defmodule Changelog.Fastly do
  @moduledoc """
  Pass in a URL or schema struct to `purge` it from Fastly's cache
  """
  require Logger

  alias Changelog.{
    Files,
    HTTP,
    Episode,
    NewsAd,
    NewsItem,
    NewsSource,
    Person,
    Podcast,
    Post,
    Sponsor,
    Topic,
    UrlKit
  }

  alias ChangelogWeb.{
    EpisodeView,
    NewsAdView,
    NewsItemView,
    NewsSourceView,
    PersonView,
    PodcastView,
    PostView,
    SponsorView,
    TopicView
  }

  def endpoint(path), do: "https://api.fastly.com" <> path

  def purge(episode = %Episode{}) do
    episode = Episode.preload_podcast(episode)

    if episode.audio_file do
      episode |> EpisodeView.audio_direct_url() |> purge()
    end

    if episode.plusplus_file do
      episode |> EpisodeView.plusplus_url() |> purge()
    end

    if episode.cover do
      for version <- Files.Cover.__versions() do
        episode |> EpisodeView.cover_url(version) |> purge()
      end
    end
  end

  def purge(ad = %NewsAd{}) do
    if ad.image do
      for version <- Files.Image.__versions() do
        ad |> NewsAdView.image_url(version) |> purge()
      end
    end
  end

  def purge(item = %NewsItem{}) do
    if item.image do
      for version <- Files.Image.__versions() do
        item |> NewsItemView.image_url(version) |> purge()
      end
    end
  end

  def purge(source = %NewsSource{}) do
    if source.icon do
      for version <- Files.Image.__versions() do
        source |> NewsSourceView.icon_url(version) |> purge()
      end
    end
  end

  def purge(person = %Person{}) do
    if person.avatar do
      for version <- Files.Avatar.__versions() do
        person |> PersonView.avatar_url(version) |> purge()
      end
    end
  end

  def purge(podcast = %Podcast{}) do
    if podcast.cover do
      for version <- Files.Cover.__versions() do
        podcast |> PodcastView.cover_url(version) |> purge()
      end
    end
  end

  def purge(post = %Post{}) do
    if post.image do
      for version <- Files.Image.__versions() do
        post |> PostView.image_url(version) |> purge()
      end
    end
  end

  def purge(sponsor = %Sponsor{}) do
    if sponsor.avatar do
      for version <- Files.Avatar.__versions() do
        sponsor |> SponsorView.avatar_url(version) |> purge()
      end
    end

    if sponsor.color_logo do
      for version <- Files.ColorLogo.__versions() do
        sponsor |> SponsorView.logo_url(:color_logo, version) |> purge()
      end
    end

    if sponsor.dark_logo do
      for version <- Files.DarkLogo.__versions() do
        sponsor |> SponsorView.logo_url(:dark_logo, version) |> purge()
      end
    end

    if sponsor.light_logo do
      for version <- Files.LightLogo.__versions() do
        sponsor |> SponsorView.logo_url(:light_logo, version) |> purge()
      end
    end
  end

  def purge(topic = %Topic{}) do
    if topic.icon do
      for version <- Files.Image.__versions() do
        topic |> TopicView.icon_url(version) |> purge()
      end
    end
  end

  def purge(url) do
    auth = Application.get_env(:changelog, :fastly_token)
    url = UrlKit.sans_scheme(url)

    case HTTP.post(endpoint("/purge/#{url}"), "", [{"Fastly-Key", auth}]) do
      {:ok, %{status_code: 200, body: body}} -> Jason.decode(body)
      {:ok, %{body: body}} ->
        {:ok, details} = Jason.decode(body)
        Sentry.capture_message("Fastly purge failing", extra: details)
        {:error, details}
    end
  end
end
