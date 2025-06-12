defmodule Changelog.Pipedream do
  @moduledoc """
  Pass in a URL or schema struct to `purge` it from Pipedream's cache
  """
  require Logger

  alias Changelog.HTTP

  def purge(url) do
    uri = URI.parse(url)
    host = uri.host

    case Changelog.Dns.aaaa("cdn-2025-02-25.internal") do
      {:ok, addresses} ->
        addresses
        |> Task.async_stream(
          fn address ->
            new_uri = Map.merge(uri, %{scheme: "http", port: 9000, host: address})

            case HTTP.request(:purge, URI.to_string(new_uri), "", [{"Host", host}]) do
              {:ok, _response} ->
                :ok

              {:error, response} ->
                Sentry.capture_message("Pipedream purge failing: Instance #{address}",
                  extra: response
                )
            end
          end,
          max_concurrency: length(addresses)
        )
        |> Stream.run()

      {:error, reason} ->
        Sentry.capture_message("Pipedream purge failing: It's always DNS", extra: reason)
    end
  end
end
