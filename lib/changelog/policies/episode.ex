defmodule Changelog.Policies.Episode do
  use Changelog.Policies.Default

  # Episode policy is based on owner podcast, which is always available
  def new(actor, podcast), do: create(actor, podcast)
  def create(actor, podcast), do: is_admin(actor) || is_host(actor, podcast)
  def index(actor, podcast), do: is_admin(actor) || is_host(actor, podcast)
  def show(actor, podcast), do: is_admin(actor) || is_host(actor, podcast)
  def update(actor, podcast), do: is_admin(actor) || is_host(actor, podcast)
  def delete(actor, _), do: is_admin(actor)

  def publish(actor, _), do: is_admin(actor)
  def unpublish(actor, podcast), do: publish(actor, podcast)
  def transcript(actor, podcast), do: is_admin(actor) || is_host(actor, podcast)

  defp is_host(actor, podcast) do
    podcast
    |> Map.get(:hosts, [])
    |> Enum.member?(actor)
  end
end
