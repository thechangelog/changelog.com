defmodule ChangelogWeb.Admin.EpisodeView do
  use ChangelogWeb, :admin_view

  alias Changelog.{Topic, Episode, EpisodeStat, Person, Sponsor}
  alias ChangelogWeb.{EpisodeView, PersonView, TimeView}
  alias ChangelogWeb.Admin.GoogleCalendarView

  def audio_filename(episode), do: EpisodeView.audio_filename(episode)
  def audio_url(episode), do: EpisodeView.audio_url(episode)
  def embed_code(episode), do: EpisodeView.embed_code(episode)
  def embed_code(episode, podcast), do: EpisodeView.embed_code(episode, podcast)
  def embed_iframe(episode, theme), do: EpisodeView.embed_iframe(episode, theme)
  def embed_iframe(episode, podcast, theme), do: EpisodeView.embed_iframe(episode, podcast, theme)
  def megabytes(episode), do: EpisodeView.megabytes(episode)
  def numbered_title(episode), do: EpisodeView.numbered_title(episode)

  def download_count(episode), do: episode.download_count |> round |> comma_separated
  def reach_count(episode) do
    if episode.reach_count > episode.download_count do
      comma_separated(episode.reach_count)
    else
      download_count(episode)
    end
  end

  def featured_label(episode) do
    if episode.featured do
      content_tag :span, "Featured", class: "ui tiny blue basic label"
    end
  end

  def calendar_event_label(episode) do
    if Episode.is_calendar_event_scheduled(episode) do
      link content_tag(:i, "", class: "calendar icon"), to: GoogleCalendarView.event_url(episode.calendar_event_id), target: "_blank"
    else
      content_tag :i, "", class: "red exclamation icon"
    end
  end

  def percent_of_downloads(episode, count) do
     ((count / episode.download_count) * 100) |> round
  end

  def status_label(episode) do
    if episode.published do
      content_tag :span, "Published", class: "ui tiny green basic label"
    else
      content_tag :span, "Draft", class: "ui tiny yellow basic label"
    end
  end

  def show_or_preview(episode) do
    if Episode.is_public(episode) do
      :show
    else
      :preview
    end
  end

  def client_name(name) do
    case name do
      "AppleCoreMedia" -> "Apple Podcasts"
      "Mozilla" -> "Browsers"
      _else -> name
    end
  end

  def stat_date(stat) do
    {:ok, result} = Timex.format(stat.date, "{WDshort}, {M}/{D}")
    result
  end
end
