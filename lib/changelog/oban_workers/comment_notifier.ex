defmodule Changelog.ObanWorkers.CommentNotifier do
  @moduledoc """
  This module defines the Oban worker for dealing with comment notifications.
  """

  use Oban.Worker, queue: :comment_notifier

  alias Changelog.{NewsItemComment, Notifier, Repo}

  @five_mins 60 * 5

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"comment_id" => comment_id}}) do
    comment = Repo.get(NewsItemComment, comment_id)
    Notifier.notify(comment)

    :ok
  end

  @doc """
  """
  def schedule_notification(%NewsItemComment{id: id}) do
    %{comment_id: id}
    |> __MODULE__.new(schedule_in: @five_mins)
    |> Oban.insert()
  end
end
