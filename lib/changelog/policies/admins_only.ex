defmodule Changelog.Policies.AdminsOnly do
  use Changelog.Policies.Default

  def create(actor), do: is_admin(actor)
  def index(actor), do: is_admin(actor)
  def show(actor, _), do: is_admin(actor)
  def update(actor, _), do: is_admin(actor)
  def delete(actor, _), do: is_admin(actor)
end
