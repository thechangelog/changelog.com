defmodule Changelog.Policies.Feed do
  use Changelog.Policies.Default

  def index(actor), do: is_active_member(actor)
  def create(actor), do: is_active_member(actor)

  def update(actor, feed), do: is_owner(actor, feed)
  def delete(actor, feed), do: is_owner(actor, feed)

  defp is_active_member(nil), do: false
  defp is_active_member(actor), do: Map.get(actor, :active_membership, false)

  defp is_owner(actor, feed) do
    feed
    |> Map.get(:owner, nil)
    |> Kernel.==(actor)
  end
end
