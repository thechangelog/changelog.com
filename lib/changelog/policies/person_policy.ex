defmodule Changelog.PersonPolicy do
  use Changelog.DefaultPolicy

  def create(actor), do: is_admin(actor)
  def index(actor), do: is_admin(actor)
  def update(actor, _), do: is_admin(actor)
  def delete(actor, _), do: is_admin(actor)
end
