defmodule Changelog.ObanWorkers.FeedBouncer do
  @moduledoc """
  This module defines the Oban worker for switching inactive members'
  feeds back to public mp3s
  """
  use Oban.Worker, queue: :scheduled

  import Ecto.Changeset, only: [change: 2]

  alias Changelog.{EventLog, Feed, Policies, Repo}

  @impl Oban.Worker
  def perform(_job) do
    plusplus =
      Feed
      |> Feed.plusplus()
      |> Feed.preload_owner()
      |> Repo.all()

      for feed = %{owner: owner} <- plusplus do
        if !Policies.Feed.plusplus(owner) do
          {:ok, feed} = feed |> change(%{plusplus: false}) |> Repo.update()
          log("Turned off pluplus for feed ##{feed.id} owned by inactive member ##{owner.id} (#{owner.email})")
          Changelog.ObanWorkers.FeedUpdater.queue(feed)
        end
      end

      :ok
  end

  defp log(message) do
    EventLog.insert(message, "FeedBouncer")
  end
end
