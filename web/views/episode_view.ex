defmodule Changelog.EpisodeView do
  use Changelog.Web, :view

  alias Changelog.PersonView

  def audio_filename(episode) do
    Changelog.AudioFile.filename(:original, {episode.audio_file.file_name, episode}) <> ".mp3"
  end

  def audio_url(episode) do
    if episode.audio_file do
      episode
      |> audio_local_path
      |> String.replace_leading(Application.app_dir(:changelog, "priv"), "")
    else
      static_url(Changelog.Endpoint, "/california.mp3")
    end
  end

  def audio_local_path(episode) do
    Changelog.AudioFile.url({episode.audio_file.file_name, episode}, :original)
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

  def numbered_title(episode) do
    episode_number = number(episode)

    if is_nil(episode_number) do
      episode.title
    else
      "#{episode_number}: #{episode.title}"
    end
  end
end
