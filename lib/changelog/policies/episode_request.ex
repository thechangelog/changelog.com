# Episode request policy is based on owner podcast, which is always available
defmodule Changelog.Policies.EpisodeRequest do
  use Changelog.Policies.Default

  def index(actor, podcast), do: is_admin(actor) || is_host(actor, podcast)
  def show(actor, podcast), do: is_admin(actor) || is_host(actor, podcast)
  def update(actor, podcast), do: is_admin(actor) || is_host(actor, podcast)
  def decline(actor, podcast), do: is_admin(actor) || is_host(actor, podcast)
  def delete(actor, _), do: is_admin(actor)

  defp is_host(actor, podcast) do
    podcast
    |> Map.get(:hosts, [])
    |> Enum.member?(actor)
  end
end
