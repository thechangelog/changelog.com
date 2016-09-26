defmodule Craisin do
  use HTTPoison.Base

  require Logger

  @auth Base.encode64((System.get_env("CM_API_TOKEN") || "") <> ":x")

  defp process_url(url) do
    "https://api.createsend.com/api/v3.1/#{url}.json"
  end

  defp process_request_headers(headers) do
    Enum.into(headers, [{"Authorization", "Basic #{@auth}"}])
  end

  defp process_response_body(body), do: JSX.decode!(body)

  def handle({:ok, %HTTPoison.Response{status_code: 200, body: body}}), do: body
  def handle({:ok, %HTTPoison.Response{status_code: 401, body: body}}) do
    Logger.debug(body["Message"])
    %{}
  end
  def handle({:error, %HTTPoison.Error{reason: reason}}) do
    Logger.debug(elem(reason, 1))
    %{}
  end
end
