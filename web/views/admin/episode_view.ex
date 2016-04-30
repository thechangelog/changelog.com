defmodule Changelog.Admin.EpisodeView do
  use Changelog.Web, :view

  alias Changelog.{Admin, EpisodeView, TimeView}

  def audio_filename(episode), do: EpisodeView.audio_filename(episode)
  def audio_url(episode), do: EpisodeView.audio_url(episode)
  def megabytes(episode), do: EpisodeView.megabytes(episode)
end
