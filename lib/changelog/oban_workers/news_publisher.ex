defmodule Changelog.ObanWorkers.NewsPublisher do
  use Oban.Worker, queue: :scheduled

  alias Changelog.NewsQueue

  @impl Oban.Worker
  def perform(_job) do
    {:ok, NewsQueue.publish()}
  end
end
