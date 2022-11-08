defmodule Changelog.ObanWorkers.AudioUpdater do
  require Logger
  @moduledoc """
  This module defines the Oban worker for updating mp3 audio files
  """
  use Oban.Worker, queue: :audio_updater

  alias Changelog.{Episode, Fastly, Mp3Kit, Repo, UrlKit}
  alias Changelog.Files.{Audio, PlusPlus}
  alias ChangelogWeb.EpisodeView

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"episode_id" => episode_id}}) do
    episode = Episode |> Repo.get(episode_id) |> Episode.preload_all()

    update_audio_file(episode)
    update_plusplus_file(episode)

    Logger.info "Purging Fastly"
    Fastly.purge(episode)

    :ok
  end

  defp update_audio_file(%{audio_file: nil}), do: Logger.info "No audio file"
  defp update_audio_file(episode) do
    url = EpisodeView.audio_direct_url(episode)
    name = Path.basename(url)
    Logger.info "Downloading audio file: #{url}"
    path = UrlKit.get_tempfile(url)

    Logger.info "Tagging audio file"
    Mp3Kit.tag(path, episode, episode.audio_chapters)
    Logger.info "Uploading audio file"

    case Audio.store({%{filename: name, path: path}, episode}) do
      {:ok, _} -> Logger.info "Upload succeeded"
      {:error, _} -> Logger.info "Upload failed"
    end

    Logger.info "Deleting tempfile: #{path}"
    File.rm(path)
  end

  defp update_plusplus_file(%{plusplus_file: nil}), do: Logger.info "No plusplus file"
  defp update_plusplus_file(episode) do
    url = EpisodeView.plusplus_url(episode)
    name = Path.basename(url)
    Logger.info "Downloading pluplus file: #{url}"
    path = UrlKit.get_tempfile(url)

    Logger.info "Tagging plusplus file"
    Mp3Kit.tag(path, episode, episode.plusplus_chapters)
    Logger.info "Uploading plusplus file"

    case PlusPlus.store({%{filename: name, path: path}, episode}) do
      {:ok, _} -> Logger.info "Upload succeeded"
      {:error, _} -> Logger.info "Upload failed"
    end

    Logger.info "Deleting tempfile: #{path}"
    File.rm(path)
  end

  @doc """
  Queues an episode for its audio to be updated
  """
  def queue(%Episode{id: id}) do
    %{"episode_id" => id}
    |> new()
    |> Oban.insert()
  end
end
