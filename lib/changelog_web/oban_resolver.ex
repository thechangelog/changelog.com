defmodule ChangelogWeb.ObanResolver do
  @behaviour Oban.Web.Resolver

  @impl true
  def resolve_user(conn) do
    conn.assigns.current_user
  end

  @impl true
  def resolve_access(user) do
    if Changelog.Policies.AdminsOnly.index(user) do
      :all
    else
      nil
    end
  end
end
