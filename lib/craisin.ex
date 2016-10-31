defmodule Craisin do
  use HTTPoison.Base

  require Logger

  defp auth do
    Application.get_env(:changelog, Craisin, [])
    |> Keyword.get(:api_token, "")
    |> Kernel.||("")
    |> Kernel.<>(":x")
    |> Base.encode64
  end

  defp process_url(url) do
    "https://api.createsend.com/api/v3.1/#{url}.json"
  end

  defp process_request_headers(headers) do
    Enum.into(headers, [{"Authorization", "Basic #{auth}"}])
  end

  defp process_response_body(body), do: JSX.decode!(body)

  def handle({:ok, %HTTPoison.Response{status_code: 200, body: body}}), do: body
  def handle({:ok, %HTTPoison.Response{status_code: 401, body: body}}) do
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
