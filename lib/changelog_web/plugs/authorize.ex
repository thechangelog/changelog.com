defmodule ChangelogWeb.Plug.Authorize do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, policy_module) when not is_list(policy_module),
    do: call(conn, [policy_module, nil])

  def call(conn, [policy_module, resource_name]) do
    user = conn.assigns.current_user
    resource = conn.assigns[resource_name]

    if apply_policy(policy_module, action_name(conn), user, resource) do
      conn
    else
      conn
      |> put_flash(:result, "failure")
      |> redirect(to: ChangelogWeb.Plug.Conn.referer_or_root_path(conn))
      |> halt()
    end
  end

  defp apply_policy(module, action, user, nil), do: apply(module, action, [user])
  defp apply_policy(module, action, user, resource), do: apply(module, action, [user, resource])
end
