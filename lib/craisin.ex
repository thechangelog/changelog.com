defmodule Craisin do
  use HTTPoison.Base

  require Logger

  defp process_url(url) do
    "https://api.createsend.com/api/v3.1/#{url}.json"
  end

  defp process_request_headers(headers) do
    auth = Application.get_env(:changelog, :cm_api_token)
    Enum.into(headers, [{"Authorization", "Basic #{auth}"}])
  end

  defp process_response_body(body), do: JSX.decode!(body)

  def handle({:ok, %HTTPoison.Response{status_code: 200, body: body}}), do: body
  def handle({:ok, %HTTPoison.Response{status_code: code, body: body}}) when code > 400 do
    log(body["Message"])
    %{}
  end
  def handle({:error, %HTTPoison.Error{reason: reason}}) do
    if is_tuple(reason) do
      log(elem(reason, 1))
    else
      log(reason)
    end

    %{}
  end

  defp log(message) do
    Logger.debug("Craisin: #{message}")
  end
end
