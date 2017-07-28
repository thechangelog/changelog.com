defmodule Changelog.GithubController do
  use Changelog.Web, :controller

  alias Changelog.Transcripts.{Source, Updater}

  require Logger

  def event(conn, params) do
    case get_req_header(conn, "x-github-event") do
      ["push"] -> push_event(conn, params)
      [event] -> unsupported_event(conn, params, event)
    end
  end

  defp push_event(conn, params = %{"repository" => %{"full_name" => repo}, "commits" => commits}) do
    if repo == Source.repo_name() do
      commits
      |> Enum.map(&(Map.take(&1, ["added", "modified"])))
      |> Enum.map(&Map.values/1)
      |> List.flatten
      |> Updater.update

      json(conn, %{})
    else
      unsupported_event(conn, params, "push #{repo}")
    end
  end

  defp push_event(conn, params) do
    unsupported_event(conn, params, "push fail")
  end

  defp unsupported_event(conn, params, event) do
    Logger.info("GitHub: Unhandled event '#{event}' params: #{inspect(params)}")

    send_resp(conn, :method_not_allowed, "")
  end
end
