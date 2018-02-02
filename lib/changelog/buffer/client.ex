defmodule Changelog.Buffer.Client do
  use HTTPoison.Base

  require Logger

  def process_url(url) do
    auth = Application.get_env(:changelog, :buffer_token)
    "https://api.bufferapp.com/1/#{url}.json?access_token=#{auth}"
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
  def handle({:ok, %{status_code: 400, body: %{"code" => code, "message" => message}}}) do
    log("error #{code}: #{message}")
  end
  def handle({:error, %{reason: reason}}) do
    log(reason)
  end

  def create(profiles, text, media \\ [])
  def create(profiles, text, media) when is_binary(profiles), do: create([profiles], text, media)
  def create(profiles, text, media) when is_list(profiles) do
    required_params = [{"profile_ids[]", profiles}, {"text", text}]
    media_params =  Enum.map(media, fn({k, v}) -> {"media[#{k}]", v} end)
    post("updates/create", {:form, required_params ++ media_params}) |> handle
  end

  def profiles do
    get("profiles") |> handle
  end

  defp log(message) do
    Logger.debug("Buffer: #{message}")
  end
end
