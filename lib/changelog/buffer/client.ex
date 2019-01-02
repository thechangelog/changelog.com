defmodule Changelog.Buffer.Client do
  use HTTPoison.Base

  require Logger

  def process_url(url) do
    auth = Application.get_env(:changelog, :buffer_token)
    "https://api.bufferapp.com/1#{url}.json?access_token=#{auth}"
  end

  def process_request_headers(headers) do
    [{"content-type", "application/x-www-form-urlencoded"} | headers]
  end

  def process_response_body(body) do
    try do
      Poison.decode!(body)
    rescue
      _ -> body
    end
  end

  def handle({:ok, %{status_code: 200, body: body}}), do: body
  def handle({:ok, %{status_code: code, body: body}}) when code > 400, do: log(body["error"])
  def handle({:error, %{reason: reason}}), do: log(reason)

  def create(profiles, text, media \\ [])
  def create(profiles, text, media) when is_binary(profiles), do: create([profiles], text, media)
  def create(profiles, text, media) when is_list(profiles) do
    params = [
      {"text", text},
      profile_list_to_params(profiles),
      media_list_to_params(media)
    ] |> List.flatten

    "/updates/create" |> post({:form, params}) |> handle
  end

  def profiles, do: "/profiles" |> get |> handle

  defp media_list_to_params(media) do
    media
    |> Enum.reject(fn({_k, v}) -> is_nil(v) end)
    |> Enum.map(fn({k, v}) -> {"media[#{k}]", v} end)
  end

  defp profile_list_to_params(profiles) do
    profiles |> Enum.map(&({"profile_ids[]", &1}))
  end

  defp log(message) do
    Logger.debug(fn -> "Buffer: #{message}" end)
    message
  end
end
