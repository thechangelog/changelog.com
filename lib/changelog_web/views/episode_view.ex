defmodule ChangelogWeb.EpisodeView do
  use ChangelogWeb, :public_view

  import ChangelogWeb.Meta.{Title, Description}

  alias Changelog.{Episode, Files, Github}
  alias ChangelogWeb.{Endpoint, LayoutView, NewsItemView, PersonView,
                      PodcastView, SponsorView, TimeView}

  def admin_edit_link(conn, user, episode) do
    if user && user.admin do
      path = admin_podcast_episode_path(conn, :edit, episode.podcast.slug, episode.slug, next: current_path(conn))
      content_tag(:span) do
        [
          link("[Edit]", to: path, data: [turbolinks: false]),
          content_tag(:span, " (#{comma_separated(episode.reach_count)})")
        ]
      end
    end
  end

  def audio_filename(episode) do
    Files.Audio.filename(:original, {episode.audio_file.file_name, episode}) <> ".mp3"
  end

  def audio_local_path(episode) do
    {episode.audio_file.file_name, episode}
    |> Files.Audio.url(:original)
    |> String.replace_leading("/priv", "priv") # remove Arc's "/" when storage is priv
  end

  def audio_path(episode) do
    if episode.audio_file do
      episode
      |> audio_local_path
      |> String.replace_leading("priv", "") # ensure relative reference is removed
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
    ~s{<audio data-theme="night" data-src="#{episode_url(Endpoint, :embed, podcast.slug, episode.slug)}" src="#{audio_url(episode)}" preload="none" class="changelog-episode" controls></audio>} <>
    ~s{<p><a href="#{episode_url(Endpoint, :show, podcast.slug, episode.slug)}">#{podcast.name} #{numbered_title(episode)}</a> – Listen on <a href="#{root_url(Endpoint, :index)}">Changelog.com</a></p>} <>
    ~s{<script async src="//cdn.changelog.com/embed.js"></script>}
  end

  def embed_iframe(episode, theme), do: embed_iframe(episode, episode.podcast, theme)
  def embed_iframe(episode, podcast, theme) do
    ~s{<iframe src="#{episode_url(Endpoint, :embed, podcast.slug, episode.slug)}?theme=#{theme}" width="100%" height=220 scrolling=no frameborder=no></iframe>}
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

  def participants(episode) do
    Episode.participants(episode)
  end

  def podcast_name_and_number(episode) do
    "#{episode.podcast.name} #{number_with_pound(episode)}"
  end

  def sponsorships_with_dark_logo(episode) do
    Enum.reject(episode.episode_sponsors, fn(s) -> is_nil(s.sponsor.dark_logo) end)
  end

  def show_notes_source_url(episode) do
    Github.Source.new("show-notes", episode).html_url
  end

  def transcript_source_url(episode) do
    Github.Source.new("transcripts", episode).html_url
  end

  def render("play.json", %{podcast: podcast, episode: episode, prev: prev, next: next}) do
    info = %{
      podcast: podcast.name,
      title: episode.title,
      number: number(episode),
      duration: episode.duration,
      art_url: PodcastView.cover_url(podcast, :small),
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

  def render("share.json", %{podcast: podcast, episode: episode}) do
    url = episode_url(Endpoint, :show, podcast.slug, episode.slug)

    %{url: url,
      twitter: tweet_url(episode.title, url),
      hackernews: hackernews_url(episode.title, url),
      reddit: reddit_url(episode.title, url),
      facebook: facebook_url(url),
      embed: embed_code(episode)}
  end
end
