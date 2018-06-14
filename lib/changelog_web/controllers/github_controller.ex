defmodule ChangelogWeb.GithubController do
  use ChangelogWeb, :controller

  alias Changelog.Github

  require Logger

  def event(conn, params) do
    case get_req_header(conn, "x-github-event") do
      ["push"] -> push_event(conn, params)
      [event] -> unsupported_event(conn, params, event)
    end
  end

  defp push_event(conn, params = %{"repository" => %{"full_name" => full_name}, "commits" => commits}) do
    case extract_supported_repository_from(full_name) do
      %{"repo" => repo} ->
        update_list = added_or_modified_files(commits)
        Github.Puller.update(repo, update_list)
        json(conn, %{})
      nil -> unsupported_event(conn, params, "push #{full_name}")
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

  defp extract_supported_repository_from(full_name) do
    Regex.named_captures(Github.Source.repo_regex(), full_name)
  end

  defp unsupported_event(conn, params, event) do
    Logger.info("GitHub: Unhandled event '#{event}' params: #{inspect(params)}")

    send_resp(conn, :method_not_allowed, "")
  end
end
