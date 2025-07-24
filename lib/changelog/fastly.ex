defmodule Changelog.Fastly do
  @moduledoc """
  Pass in a URL or schema struct to `purge` it from Fastly's cache
  """
  require Logger

  alias Changelog.{HTTP, UrlKit}

  def endpoint(path), do: "https://api.fastly.com" <> path

  def purge(url) do
    auth = Application.get_env(:changelog, :fastly_token)
    url = UrlKit.sans_scheme(url)

    case HTTP.post(endpoint("/purge/#{url}"), "", [{"Fastly-Key", auth}]) do
      {:ok, %{status_code: 200, body: body}} ->
        Jason.decode(body)

      {:ok, %{body: body}} ->
        {:ok, details} = Jason.decode(body)
        Sentry.capture_message("Fastly purge failing", extra: details)
        {:error, details}
    end
  end
end
