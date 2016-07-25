defmodule Changelog.EpisodeView do
  use Changelog.Web, :view

  alias Changelog.{PersonView, SharedView, PodcastView, SponsorView, TimeView}

  def audio_filename(episode) do
    Changelog.AudioFile.filename(:original, {episode.audio_file.file_name, episode}) <> ".mp3"
  end

  def audio_url(episode) do
    if episode.audio_file do
      episode
      |> audio_local_path
      |> String.replace_leading("priv", "")
    else
      "/california.mp3"
    end

    static_url(Changelog.Endpoint, url)
  end

  def audio_local_path(episode) do
    Changelog.AudioFile.url({episode.audio_file.file_name, episode}, :original)
  end

  def classy_highlight(episode) do
    episode.highlight
    |> no_widowed_words
    |> with_smart_quotes
    |> raw
  end

  def guid(episode) do
    episode.guid || "changelog.com/#{episode.podcast_id}/#{episode.id}"
  end

  def megabytes(episode) do
    round((episode.bytes || 0) / 1000 / 1000)
  end

  def number(episode) do
    case Float.parse(episode.slug) do
      {_, _} -> episode.slug
      :error -> nil
    end
  end

  def number_with_pound(episode) do
    if episode_number = number(episode) do
      "##{episode_number}"
    end
  end

  def numbered_title(episode) do
    episode_number = number(episode)

    if is_nil(episode_number) do
      episode.title
    else
      "#{episode_number}: #{episode.title}"
    end
  end

  def sponsorships_with_light_logo(episode) do
    Enum.reject(episode.episode_sponsors, fn(s) -> is_nil(s.sponsor.light_logo) end)
  end

  def sponsorships_with_dark_logo(episode) do
    Enum.reject(episode.episode_sponsors, fn(s) -> is_nil(s.sponsor.dark_logo) end)
  end

  def render("play.json", %{podcast: podcast, episode: episode, prev: prev, next: next}) do
    info = %{
      podcast: podcast.name,
      title: episode.title,
      duration: episode.duration,
      art_url: static_url(Changelog.Endpoint, "/images/podcasts/#{podcast.slug}-cover-art.svg"),
      audio_url: audio_url(episode),
      share_url: "#{Changelog.PodcastView.vanity_domain_with_fallback_url(podcast)}/#{episode.slug}"
    }

    info = if prev do
      Map.put(info, :prev, %{
        number: prev.slug,
        url: episode_path(Changelog.Endpoint, :play, podcast.slug, prev.slug)
      })
    else
      info
    end

    info = if next do
      Map.put(info, :next, %{
        number: next.slug,
        url: episode_path(Changelog.Endpoint, :play, podcast.slug, next.slug)
      })
    else
      info
    end

    info
  end
end
