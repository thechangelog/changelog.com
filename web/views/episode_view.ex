defmodule Changelog.EpisodeView do
  use Changelog.Web, :view

  alias Changelog.{AudioFile, Endpoint, LayoutView, PersonView, SharedView, PodcastView, SponsorView, TimeView}

  import Changelog.Meta.{Title, Description}

  def audio_filename(episode) do
    AudioFile.filename(:original, {episode.audio_file.file_name, episode}) <> ".mp3"
  end

  def audio_local_path(episode) do
    AudioFile.url({episode.audio_file.file_name, episode}, :original)
    |> String.replace(~r{^/}, "") # Arc 0.6 now prepends / to *all* URLs
  end

  def audio_path(episode) do
    if episode.audio_file do
      episode
      |> audio_local_path
      |> String.replace_leading("priv", "")
    else
      "/california.mp3"
    end
  end

  def audio_url(episode) do
    static_url(Endpoint, audio_path(episode))
  end

  def classy_highlight(episode) do
    episode.highlight
    |> no_widowed_words
    |> with_smart_quotes
    |> raw
  end

  def embed_code(episode), do: embed_code(episode, episode.podcast)
  def embed_code(episode, podcast) do
    ~s{<audio src="#{audio_url(episode)}" preload="none" class="changelog-episode" data-src="#{episode_url(Endpoint, :embed, podcast.slug, episode.slug)}" data-theme="night" controls></audio>} <>
    ~s{<p><a href="#{episode_url(Endpoint, :show, podcast.slug, episode.slug)}">#{podcast.name} #{numbered_title(episode)}</a> – Listen on <a href="#{page_url(Endpoint, :home)}">Changelog.com</a></p>} <>
    ~s{<script async src="//cdn.changelog.com/embed.js"></script>}
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

  def numbered_title(episode, prefix \\ "") do
    episode_number = number(episode)

    if is_nil(episode_number) do
      episode.title
    else
      "#{prefix}#{episode_number}: #{episode.title}"
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
      number: number(episode),
      duration: episode.duration,
      art_url: static_url(Endpoint, "/images/podcasts/#{podcast.slug}-cover-art.svg"),
      audio_url: audio_url(episode),
      share_url: "#{PodcastView.vanity_domain_with_fallback_url(podcast)}/#{episode.slug}"
    }

    info = if prev do
      Map.put(info, :prev, %{
        number: prev.slug,
        title: prev.title,
        location: episode_path(Endpoint, :play, podcast.slug, prev.slug),
        audio_url: audio_url(prev)
      })
    else
      info
    end

    info = if next do
      Map.put(info, :next, %{
        number: next.slug,
        title: next.title,
        location: episode_path(Endpoint, :play, podcast.slug, next.slug),
        audio_url: audio_url(next)
      })
    else
      info
    end

    info
  end
end
