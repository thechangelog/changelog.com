defmodule ChangelogWeb.Plug.PublicEtsCache do
  @moduledoc """
  This is identical to PlugEtsCache.Plug except we bypass the lookup for signed
  in users
  """
  use Plug.Builder

  plug(:lookup)

  def lookup(conn = %{assigns: %{current_user: user}}, _opts) when not is_nil(user), do: conn
  def lookup(conn, _opts) do
    case PlugEtsCache.Store.get(conn) do
      nil -> conn
      result ->
        conn
        |> put_resp_content_type(result.type, nil)
        |> send_resp(200, result.value)
        |> halt
    end
  end
end
