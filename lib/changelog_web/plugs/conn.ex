defmodule ChangelogWeb.Plug.Conn do
  @moduledoc """
  General-purpose, connection-related functions available to controllers.
  """

  import Plug.Conn
  require Logger

  alias ChangelogWeb.Router

  @doc """
  Extracts the user agent from a connection's headers
  """
  def get_agent(conn), do: get_header(conn, "user-agent")

  @doc """
  Extracts the host from a connection's headers, starting with `forwarded-host`
  """
  def get_host(conn) do
    host = get_header(conn, "x-forwarded-host") || get_header(conn, "host") || Map.get(conn, :host, nil)

    host
    |> to_string()
    |> String.split(":")
    |> List.first()
  end

  @doc """
  Extracts the local referer (path) from a connection's headers. Useful for
  redirecting back to previous page.
  """
  def get_local_referer(conn) do
    referer =
      conn
      |> get_header("referer", "")
      |> URI.parse()

    if referer.host == get_host(conn) do
      referer
      |> Map.merge(%{authority: nil, host: nil, scheme: nil, port: nil})
      |> URI.to_string()
    else
      nil
    end
  end

  @doc """
  Extracts and returns the request referer, falling back to the root path
  """
  def referer_or_root_path(conn) do
    with {:ok, referer} <- extract_referer(conn),
         {:ok, path} <- extract_local_path(conn, referer) do
      path
    else
      _fail -> Router.Helpers.root_path(conn, :index)
    end
  end

  # returns first header for `key` or nil
  defp get_header(conn, key) do
    conn |> get_req_header(key) |> List.first()
  end

  defp get_header(conn, key, fallback) do
    conn |> get_req_header(key) |> Enum.at(0, fallback)
  end

  defp extract_referer(conn) do
    if referer = get_header(conn, "referer") do
      {:ok, referer}
    else
      {:error, "no referer header"}
    end
  end

  defp extract_local_path(conn, referer) do
    uri = URI.parse(referer)
    path = Map.get(uri, :path)

    cond do
      uri.host != get_host(conn) -> {:error, "external referer"}
      String.starts_with?(path, "//") -> {:error, "invalid path"}
      true -> {:ok, path}
    end
  end
end
