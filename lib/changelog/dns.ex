defmodule Changelog.Dns do
  @moduledoc """
  DNS utilities for resolving machine addresses, particularly IPv6 AAAA records.

  This module provides functionality to resolve IPv6 addresses for a list of machines,
  similar to the `dig` command with AAAA record queries.
  """

  require Logger

  @doc """
  Resolves AAAA records (IPv6 addresses) for a single hostname.

  Returns `{:ok, [addresses]}` on success or `{:error, reason}` on failure.

  ## Examples

      iex> Changelog.Dns.aaaa("example.com")
      {:ok, ["2606:2800:220:1:248:1893:25c8:1946"]}

      iex> Changelog.Dns.aaaa("nonexistent.domain")
      {:error, :nxdomain}
  """
  def aaaa(""), do: {:ok, []}
  def aaaa(nil), do: {:ok, []}

  def aaaa(hostname) when is_binary(hostname) do
    case :inet_res.lookup(String.to_charlist(hostname), :in, :aaaa) do
      [] ->
        {:error, :not_found}

      addresses ->
        ipv6_strings =
          addresses
          |> Enum.map(&format_ipv6_address/1)
          |> Enum.reject(&is_nil/1)

        case ipv6_strings do
          [] -> {:error, :invalid_addresses}
          valid_addresses -> {:ok, valid_addresses}
        end
    end
  rescue
    error ->
      Logger.warning("DNS resolution failed for #{hostname}: #{inspect(error)}")
      {:error, :dns_error}
  end

  defp format_ipv6_address(address_tuple) when is_tuple(address_tuple) do
    case :inet.ntoa(address_tuple) do
      formatted when is_list(formatted) ->
        to_string(formatted)

      _ ->
        nil
    end
  rescue
    _ -> nil
  end
end
