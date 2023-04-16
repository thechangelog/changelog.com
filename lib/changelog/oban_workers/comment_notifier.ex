defmodule Changelog.ObanWorkers.CommentNotifier do
  @moduledoc """
  This module defines the Oban worker for dealing with comment notifications.
  """

  use Oban.Worker, queue: :email

  alias Changelog.{NewsItemComment, Notifier, Repo}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"comment_id" => comment_id}}) do
    comment = Repo.get(NewsItemComment, comment_id)
    Notifier.notify(comment)

    :ok
  end

  @doc """
  Schedules the notification to be sent out 5 mins in the future
  """
  def schedule(%NewsItemComment{id: id}) do
    %{comment_id: id}
    |> new(schedule_in: {5, :minutes})
    |> Oban.insert()
  end
end
