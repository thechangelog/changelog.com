defmodule Changelog.Admin.EpisodeView do
  use Changelog.Web, :view

  import Scrivener.HTML

  alias Changelog.{EpisodeView, TimeView}

  def audio_filename(episode), do: EpisodeView.audio_filename(episode)
  def audio_url(episode), do: EpisodeView.audio_url(episode)
  def megabytes(episode), do: EpisodeView.megabytes(episode)

  def status_label(episode) do
    if episode.published do
      content_tag :span, "Published", class: "ui tiny green label"
    else
      content_tag :span, "Draft", class: "ui tiny yellow label"
    end
  end
end
