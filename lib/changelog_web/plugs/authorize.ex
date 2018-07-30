defmodule ChangelogWeb.Plug.Authorize do
  import Plug.Conn
  import Phoenix.Controller

  alias ChangelogWeb.Router.Helpers

  def init(opts), do: opts

  def call(conn, policy_module) when not is_list(policy_module), do: call(conn, [policy_module, nil])
  def call(conn, [policy_module, resource_name]) do
    user = conn.assigns.current_user
    resource = conn.assigns[resource_name]

    if apply_policy(policy_module, action_name(conn), user, resource) do
      conn
    else
      conn
      |> put_flash(:result, "failure")
      |> redirect(to: referer_or_root_path(conn))
      |> halt()
    end
  end

  defp apply_policy(module, action, user, nil), do: apply(module, action, [user])
  defp apply_policy(module, action, user, resource), do: apply(module, action, [user, resource])

  defp referer_or_root_path(conn) do
    case conn |> get_req_header("referer") |> List.last do
      nil -> Helpers.root_path(conn, :index)
      referer ->  referer |> URI.parse |> Map.get(:path)
    end
  end
end
