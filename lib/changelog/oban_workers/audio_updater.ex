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

    if update_audio_file(episode) || update_plusplus_file(episode) do
      Logger.info "Purging Fastly"
      Fastly.purge(episode)
    end

    :ok
  end

  defp update_audio_file(%{audio_file: nil}), do: false
  defp update_audio_file(episode) do
    url = EpisodeView.audio_url(episode)
    name = Path.basename(url)
    Logger.info "Downloading Audio mp3: #{url}"
    path = UrlKit.get_tempfile(url)

    Logger.info "Tagging Audio mp3"
    Mp3Kit.tag(path, episode, episode.audio_chapters)
    Logger.info "Uploading Audio mp3"

    did_update = case Audio.store({%{filename: name, path: path}, episode}) do
      {:ok, _} -> true
      {:error, _} -> false
    end

    Logger.info "Deleting tempfile: #{path}"
    File.rm(path)

    did_update
  end

  defp update_plusplus_file(%{plusplus_file: nil}), do: false
  defp update_plusplus_file(episode) do
    url = EpisodeView.plusplus_url(episode)
    name = Path.basename(url)
    Logger.info "Downloading PlusPlus mp3: #{url}"
    path = UrlKit.get_tempfile(url)

    Logger.info "Tagging PlusPlus mp3"
    Mp3Kit.tag(path, episode, episode.plusplus_chapters)
    Logger.info "Uploading Audio mp3"

    did_update = case Audio.store({%{filename: name, path: path}, episode}) do
      {:ok, _} -> true
      {:error, _} -> false
    end

    Logger.info "Deleting tempfile: #{path}"
    File.rm(path)

    did_update
  end
end
