defmodule Changelog.Policies.Post do
  use Changelog.Policies.Default

  def create(actor), do: is_admin_or_editor(actor)
  def index(actor), do: is_admin_or_editor(actor)
  def show(actor, post), do: is_admin(actor) || is_author(actor, post)
  def update(actor, post), do: is_admin(actor) || is_author(actor, post)
  def delete(actor, post = %{published: false}), do: is_admin(actor) || is_author(actor, post)
  def delete(_actor, _post), do: false

  def publish(actor, post), do: is_admin(actor) || is_author(actor, post)
  def unpublish(actor, post), do: publish(actor, post)

  defp is_author(nil, _post), do: false
  defp is_author(_actor, %{author: nil}), do: false
  defp is_author(actor, post) do
    post
    |> Map.get(:author, nil)
    |> Kernel.==(actor)
  end
end
