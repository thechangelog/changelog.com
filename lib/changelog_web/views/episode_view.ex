defmodule ChangelogWeb.EpisodeView do
  use ChangelogWeb, :public_view

  alias Changelog.{Episode, Files, Github, HtmlKit, ListKit, NewsItem, UrlKit}

  alias ChangelogWeb.{
    Endpoint,
    LayoutView,
    Meta,
    PersonView,
    PodcastView,
    SponsorView,
    TimeView
  }

  def admin_edit_link(conn, %{admin: true}, episode) do
    path =
      Routes.admin_podcast_episode_path(conn, :edit, episode.podcast.slug, episode.slug,
        next: SharedHelpers.current_path(conn)
      )

    content_tag(:span) do
      [
        link("(#{SharedHelpers.pretty_reach(episode)})",
          to: path,
          data: [turbolinks: false]
        )
      ]
    end
  end

  def admin_edit_link(_, _, _), do: nil

  def audio_filename(episode) do
    Files.Audio.filename(:original, {episode.audio_file.file_name, episode}) <> ".mp3"
  end

  def plusplus_filename(episode) do
    Files.PlusPlus.filename(:original, {episode.plusplus_file.file_name, episode}) <> ".mp3"
  end

  def audio_url(episode) do
    url =
      {episode.audio_file, episode}
      |> Files.Audio.url(:original)
      |> UrlKit.sans_cache_buster()

    if episode.podcast.chartable_id do
      "https://chtbl.com/track/#{episode.podcast.chartable_id}/#{url}"
    else
      url
    end
  end

  def plusplus_url(episode) do
    {episode.audio_file, episode}
    |> Files.PlusPlus.url(:original)
    |> UrlKit.sans_cache_buster()
  end

  def classy_highlight(episode) do
    episode.highlight
    |> PublicHelpers.no_widowed_words()
    |> PublicHelpers.with_smart_quotes()
    |> raw
  end

  def embed_code(episode), do: embed_code(episode, episode.podcast)

  def embed_code(episode, podcast) do
    ~s{<audio data-theme="night" data-src="#{url(episode, :embed)}" src="#{audio_url(episode)}" preload="none" class="changelog-episode" controls></audio>} <>
      ~s{<p><a href="#{url(episode, :show)}">#{podcast.name} #{numbered_title(episode)}</a> – Listen on <a href="#{Routes.root_url(Endpoint, :index)}">Changelog.com</a></p>} <>
      ~s{<script async src="//cdn.changelog.com/embed.js"></script>}
  end

  def embed_iframe(episode, theme) do
    ~s{<iframe src="#{url(episode, :embed)}?theme=#{theme}" width="100%" height=220 scrolling=no frameborder=no></iframe>}
  end

  def guest_focused_subtitle(episode) do
    if is_subtitle_guest_focused(episode), do: episode.subtitle, else: ""
  end

  def guid(episode) do
    episode.guid || "changelog.com/#{episode.podcast_id}/#{episode.id}"
  end

  def is_subtitle_guest_focused(%{subtitle: nil}), do: false
  def is_subtitle_guest_focused(%{guests: nil}), do: false
  def is_subtitle_guest_focused(%{guests: []}), do: false

  def is_subtitle_guest_focused(%{subtitle: subtitle}) do
    String.starts_with?(subtitle, "with ") ||
      String.starts_with?(subtitle, "featuring ")
  end

  def megabytes(episode, type \\ "audio") do
    bytes = Map.get(episode, String.to_existing_atom("#{type}_bytes"), 0)
    round(bytes / 1000 / 1000)
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

  def podcast_aside(episode) do
    "(#{podcast_name_and_number(episode)})"
  end

  def podcast_name_and_number(episode) do
    [episode.podcast.name, number_with_pound(episode)] |> ListKit.compact_join(" ")
  end

  def sponsorships_with_dark_logo(episode) do
    Enum.reject(episode.episode_sponsors, fn s -> is_nil(s.sponsor.dark_logo) end)
  end

  def show_notes_source_url(episode) do
    Github.Source.new("show-notes", episode).html_url
  end

  def title_with_podcast_aside(episode) do
    [
      episode.title,
      podcast_aside(episode)
    ]
    |> ListKit.compact_join(" ")
  end

  def title_with_guest_focused_subtitle_and_podcast_aside(episode = %{type: :trailer}),
    do: episode.title

  def title_with_guest_focused_subtitle_and_podcast_aside(episode) do
    [
      episode.title,
      guest_focused_subtitle(episode),
      "(#{podcast_name_and_number(episode)})"
    ]
    |> ListKit.compact_join(" ")
  end

  def transcript_url(episode) do
    Routes.episode_url(Endpoint, :show, episode.podcast.slug, episode.slug) <> "#transcript"
  end

  def transcript_source_url(episode) do
    Github.Source.new("transcripts", episode).html_url
  end

  def render("play.json", %{podcast: podcast, episode: episode, prev: prev, next: next}) do
    info = %{
      podcast: podcast.name,
      title: episode.title,
      number: number(episode),
      duration: episode.audio_duration,
      art_url: PodcastView.cover_url(podcast, :small),
      audio_url: audio_url(episode),
      share_url: share_url(episode)
    }

    info =
      if prev do
        Map.put(info, :prev, %{
          number: prev.slug,
          title: prev.title,
          location: Routes.episode_path(Endpoint, :play, podcast.slug, prev.slug),
          audio_url: audio_url(prev)
        })
      else
        info
      end

    info =
      if next do
        Map.put(info, :next, %{
          number: next.slug,
          title: next.title,
          location: Routes.episode_path(Endpoint, :play, podcast.slug, next.slug),
          audio_url: audio_url(next)
        })
      else
        info
      end

    info
  end

  def render("share.json", %{podcast: _podcast, episode: episode}) do
    url = share_url(episode)

    %{
      url: url,
      twitter: PublicHelpers.tweet_url(episode.title, url),
      hackernews: PublicHelpers.hackernews_url(episode.title, url),
      reddit: PublicHelpers.reddit_url(episode.title, url),
      facebook: PublicHelpers.facebook_url(url),
      embed: embed_code(episode)
    }
  end

  def share_url(episode) do
    episode = Episode.preload_podcast(episode)
    vanity = episode.podcast.vanity_domain

    if vanity do
      vanity <> "/" <> episode.slug
    else
      url(episode, :show)
    end
  end

  def url(episode, action) do
    episode = Episode.preload_podcast(episode)
    Routes.episode_url(Endpoint, action, episode.podcast.slug, episode.slug)
  end
end
