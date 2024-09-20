defmodule Changelog.Policies.Feed do
  use Changelog.Policies.Default

  def index(actor), do: is_admin_or_active_member(actor)

  def new(actor), do: is_admin_or_active_member(actor)
  def create(actor), do: new(actor)

  def edit(actor, feed), do: is_owner(actor, feed)
  def email(actor, feed), do: edit(actor, feed)
  def refresh(actor, feed), do: edit(actor, feed)
  def update(actor, feed), do: edit(actor, feed)
  def delete(actor, feed), do: edit(actor, feed)

  defp is_admin_or_active_member(actor) do
    is_admin(actor) || is_active_member(actor)
  end

  defp is_active_member(nil), do: false
  defp is_active_member(actor), do: is_map(Map.get(actor, :active_membership))

  defp is_owner(nil, _feed), do: false

  defp is_owner(actor, feed) do
    feed
    |> Map.get(:owner, %{})
    |> Map.get(:id)
    |> Kernel.==(actor.id)
  end
end
