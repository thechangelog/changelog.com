defmodule ChangelogWeb.Plug.ResponseCache do
  @moduledoc """
  Adds ability to store/retrieve responses in/from the app cache.

  Storage is managed by the `cache` and `cache_public` functions which must be
  called before calling `render`.

  Retrieval is handled by the `cached_response` plug which should be `plug`'d by
  any pipeline that wants to serve responses from the cache.
  """
  import Plug.Conn
  use Plug.Builder
  alias Changelog.Cache

  plug :cached_response

  def cached_response(conn = %{assigns: %{current_user: user}}, _opts) when not is_nil(user),
    do: conn

  def cached_response(conn, _opts) do
    case Cache.get(key(conn)) do
      nil ->
        conn

      result ->
        conn
        |> put_resp_content_type(result.type, nil)
        |> send_resp(200, result.value)
        |> halt()
    end
  end

  def cache_public(conn = %{assigns: %{current_user: user}}) when not is_nil(user), do: conn
  def cache_public(conn), do: cache(conn)

  def cache_public(conn = %{assigns: %{current_user: user}}, _ttl) when not is_nil(user), do: conn
  def cache_public(conn, ttl), do: cache(conn, ttl)

  def cache(conn, ttl \\ :infinity) do
    conn
    |> Map.put(:cache_ttl, ttl)
    |> register_before_send(&cache_response/1)
  end

  defp cache_response(conn = %{resp_body: body}) do
    type = conn |> get_resp_header("content-type") |> hd()
    ttl = conn |> Map.get(:cache_ttl)
    item = %{type: type, value: body, ttl: ttl}
    Cache.put(key(conn), item)
    conn
  end

  defp key(conn) do
    "#{conn.request_path}#{conn.query_string}"
  end
end
