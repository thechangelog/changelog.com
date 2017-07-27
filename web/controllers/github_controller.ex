defmodule Changelog.GithubController do
  use Changelog.Web, :controller

  require Logger

  def event(conn, params) do
    case get_req_header(conn, "x-github-event") do
      ["push"] -> push_event(conn, params)
      [event] -> unsupported_event(conn, params, event)
    end
  end

  defp push_event(conn, _params) do
    json(conn, %{})
  end

  defp unsupported_event(conn, params, event) do
    Logger.info("GitHub: Unhandled event '#{event}' params: #{inspect(params)}")

    send_resp(conn, :method_not_allowed, "")
  end
end
