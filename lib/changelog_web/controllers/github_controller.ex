defmodule ChangelogWeb.GithubController do
  use ChangelogWeb, :controller

  alias Changelog.{ShowNotes, Transcripts}

  require Logger

  def event(conn, params) do
    case get_req_header(conn, "x-github-event") do
      ["push"] -> push_event(conn, params)
      [event] -> unsupported_event(conn, params, event)
    end
  end

  defp push_event(conn, params = %{"repository" => %{"full_name" => repo}, "commits" => commits}) do
    case repo do
      "thechangelog/show-notes" ->
        commits
        |> added_or_modified_files
        |> ShowNotes.Updater.update

        json(conn, %{})
      "thechangelog/transcripts" ->
        commits
        |> added_or_modified_files
        |> Transcripts.Updater.update

        json(conn, %{})
      _else ->
        unsupported_event(conn, params, "push #{repo}")
    end
  end
  defp push_event(conn, params) do
    unsupported_event(conn, params, "push fail")
  end

  defp added_or_modified_files(commits) do
    commits
    |> Enum.map(&(Map.take(&1, ["added", "modified"])))
    |> Enum.map(&Map.values/1)
    |> List.flatten
  end

  defp unsupported_event(conn, params, event) do
    Logger.info("GitHub: Unhandled event '#{event}' params: #{inspect(params)}")

    send_resp(conn, :method_not_allowed, "")
  end
end
