defmodule Craisin do
  use HTTPoison.Base

  require Logger

  def process_url(url) do
    case String.split(url, "?") do
      [path, params] -> "https://api.createsend.com/api/v3.1#{path}.json?#{params}"
      [path] -> "https://api.createsend.com/api/v3.1#{path}.json"
    end
  end

  def process_request_headers(headers) do
    auth = Application.get_env(:changelog, :cm_api_token)
    Enum.into(headers, [{"Authorization", "Basic #{auth}"}])
  end

  def process_response_body(body) do
    try do
      Poison.decode!(body)
    rescue
      _ -> body
    end
  end

  def handle({:ok, %{status_code: code, body: body}}) when code in 200..201, do: body
  def handle({:ok, %{status_code: 400, body: body}}), do: log(body)
  def handle({:ok, %{status_code: code, body: body}}) when code > 400, do: log(body["Message"])
  def handle({:error, %{reason: reason}}) when is_tuple(reason), do: log(elem(reason, 1))
  def handle({:error, %{reason: reason}}), do: log(reason)

  defp log(message) do
    Logger.debug(fn -> "Craisin: #{message}" end)
    %{}
  end
end
