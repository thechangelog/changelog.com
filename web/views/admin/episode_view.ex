defmodule Changelog.Admin.EpisodeView do
  use Changelog.Web, :view

  import Changelog.Admin.SharedView
  import Scrivener.HTML

  alias Changelog.{Episode, EpisodeView, TimeView, Repo, EpisodeStat}

  def audio_filename(episode), do: EpisodeView.audio_filename(episode)
  def audio_url(episode), do: EpisodeView.audio_url(episode)
  def embed_code(episode), do: EpisodeView.embed_code(episode)
  def embed_code(episode, podcast), do: EpisodeView.embed_code(episode, podcast)
  def megabytes(episode), do: EpisodeView.megabytes(episode)

  def download_count(episode), do: episode.download_count |> round |> comma_separated
  def reach_count(episode) do
    if episode.reach_count > episode.download_count do
      comma_separated(episode.reach_count)
    else
      download_count(episode)
    end
  end

  def person_from_model_or_params(model, params) do
    (model |> Repo.preload(:person)).person ||
      Repo.get(Changelog.Person, (Map.get(model, "person_id") || params["person_id"]))
  end
  def sponsor_from_model_or_params(model, params) do
    (model |> Repo.preload(:sponsor)).sponsor ||
      Repo.get(Changelog.Sponsor, (Map.get(model, "sponsor_id") || params["sponsor_id"]))
  end

  def featured_label(episode) do
    if episode.featured do
      content_tag :span, "Featured", class: "ui tiny blue basic label"
    end
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
