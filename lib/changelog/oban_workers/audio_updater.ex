defmodule Changelog.ObanWorkers.AudioUpdater do
  require Logger
  @moduledoc """
  This module defines the Oban worker for updating mp3 audio files
  """
  use Oban.Worker, queue: :audio_updater

  alias Changelog.{Episode, Fastly, Mp3Kit, Repo, UrlKit}
  alias Changelog.Files.Audio
  alias ChangelogWeb.EpisodeView

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"episode_id" => episode_id}}) do
    episode = Episode |> Repo.get(episode_id) |> Episode.preload_all()

    updated_audio = if episode.audio_file do
      audio_url = EpisodeView.audio_url(episode)
      audio_name = Path.basename(audio_url)
      Logger.info "Downloading Audio mp3: #{audio_url}"
      file_path = UrlKit.get_tempfile(audio_url)

      Logger.info "Tagging Audio mp3"
      Mp3Kit.tag(file_path, episode, episode.audio_chapters)
      Logger.info "Uploading Audio mp3"

      case Audio.store({%{filename: audio_name, path: file_path}, episode}) do
        {:ok, _} -> true
        {:error, _} -> false
      end
    else
      false
    end

    updated_plusplus = if episode.plusplus_file do
      plusplus_url = EpisodeView.plusplus_url(episode)
      plusplus_name = Path.basename(plusplus_url)
      Logger.info "Downloading PlusPlus mp3: #{plusplus_url}"
      file_path = UrlKit.get_tempfile(plusplus_url)

      Logger.info "Tagging PlusPlus mp3"
      Mp3Kit.tag(file_path, episode, episode.plusplus_chapters)
      Logger.info "Uploading PlusPlus mp3"

      case Audio.store({%{filename: plusplus_name, path: file_path}, episode}) do
        {:ok, _} -> true
        {:error, _} -> false
      end
    else
      false
    end

    if updated_audio || updated_plusplus do
      Logger.info "Purging Fastly"
      Fastly.purge(episode)
    end

    :ok
  end
end
