defmodule Changelog.PersonPolicy do
  use Changelog.DefaultPolicy

  def create(actor), do: is_admin_or_host(actor)
  def index(actor), do: is_admin(actor)
  def update(actor, _), do: is_admin_or_host(actor)
  def delete(actor, _), do: is_admin(actor)

  defp is_admin_or_host(actor), do: is_admin(actor) || is_host(actor)
end
