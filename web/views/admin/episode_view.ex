defmodule Changelog.Admin.EpisodeView do
  use Changelog.Web, :view

  import Changelog.Admin.SharedView
  import Scrivener.HTML

  alias Changelog.{EpisodeView, TimeView, Repo}

  def audio_filename(episode), do: EpisodeView.audio_filename(episode)
  def audio_url(episode), do: EpisodeView.audio_url(episode)
  def megabytes(episode), do: EpisodeView.megabytes(episode)

  def channel_from_model_or_params(model, params) do
    (model |> Repo.preload(:channel)).channel ||
      Repo.get(Changelog.Channel, (Map.get(model, "channel_id") || params["channel_id"]))
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
end
