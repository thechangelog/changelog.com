defmodule Changelog.Policies.Podcast do
  use Changelog.Policies.Default

  def create(actor), do: is_admin(actor)
  def index(actor), do: is_admin_or_host(actor)
  def show(actor, podcast), do: is_admin(actor) || is_host(actor, podcast)
  def update(actor, _), do: is_admin(actor)
  def delete(actor, _), do: is_admin(actor)

  defp is_host(actor, podcast) do
    podcast
    |> Map.get(:hosts, [])
    |> Enum.member?(actor)
  end
end
