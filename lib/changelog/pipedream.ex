defmodule Changelog.Pipedream do
  @moduledoc """
  Pass in a URL or schema struct to `purge` it from Pipedream's cache
  """
  alias Changelog.HTTP

  def host, do: Application.get_env(:changelog, :pipedream_host)
  def port, do: Application.get_env(:changelog, :pipedream_port) |> String.to_integer()
  def scheme, do: Application.get_env(:changelog, :pipedream_scheme)
  def purge_token, do: Application.get_env(:changelog, :pipedream_purge_token)

  def purge(url) do
    case Changelog.Dns.aaaa(host()) do
      {:ok, addresses} ->
        addresses
        |> Task.async_stream(
          fn address ->
            case HTTP.request(:purge, purge_url(url, address), "", purge_headers(url)) do
              {:ok, %{status_code: status_code}}
              when status_code >= 200 and status_code < 300 ->
                :ok

              {:ok, response} ->
                Sentry.capture_message(
                  "Pipedream purge failing: Url: #{url}, Instance #{address}",
                  extra: response
                )

              {:error, response} ->
                Sentry.capture_message(
                  "Pipedream purge failing: Url: #{url}, Instance #{address}",
                  extra: response
                )
            end
          end,
          max_concurrency: length(addresses)
        )
        |> Stream.run()

      {:error, reason} ->
        Sentry.capture_message("Pipedream purge failing: It's always DNS",
          extra: %{message: reason}
        )
    end
  end

  defp purge_url(url, ip_address) do
    url
    |> URI.parse()
    |> Map.merge(%{scheme: scheme(), port: port(), host: ip_address})
    |> URI.to_string()
  end

  defp purge_headers(url) do
    purge_token = purge_token()
    headers = [{"Host", URI.parse(url).host}]

    if purge_token do
      headers ++ [{"Purge-Token", purge_token}]
    else
      headers
    end
  end
end
