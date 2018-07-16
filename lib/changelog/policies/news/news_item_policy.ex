defmodule Changelog.NewsItemPolicy do
  use Changelog.DefaultPolicy

  def create(actor), do: is_admin(actor) || is_editor(actor)
  def index(actor), do: is_admin(actor) || is_editor(actor)
  def update(actor, item), do: is_admin(actor) || is_logger(actor, item)
  def move(actor, _), do: is_admin(actor)
  def decline(actor, _), do: is_admin(actor)
  def delete(actor, _), do: is_admin(actor)
  def unpublish(actor, _), do: is_admin(actor)

  defp is_logger(nil, _item), do: false
  defp is_logger(_actor, %{logger: nil}), do: false
  defp is_logger(actor, item) do
    item
    |> Map.get(:logger, nil)
    |> Kernel.==(actor)
  end
end
