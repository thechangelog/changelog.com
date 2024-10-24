defmodule Changelog.ObanWorkers.OvercastPinger do
  @moduledoc """
  This module defines the Oban worker for pinging Overcast about new episodes.
  Each unique URL can only be queued once every five minutes.
  """
  use Oban.Worker,
    queue: :scheduled,
    unique: [fields: [:args], period: {5, :minutes}]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"url" => url}}) do
    case Changelog.PodPing.overcast(url) do
      {:ok, %{status_code: 200}} -> :ok
      {:ok, %{status_code: 429, body: body}} -> {:error, body}
    end
  end

  def queue(url, opts) do
    %{"url" => url}
    |> new(opts)
    |> Oban.insert()
  end
end
