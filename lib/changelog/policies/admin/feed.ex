defmodule Changelog.Policies.Admin.Feed do
  use Changelog.Policies.Default

  def index(actor), do: is_admin(actor)
  def show(actor, _feed), do: is_admin(actor)
  def agents(actor, feed), do: show(actor, feed)
  def create(actor), do: is_admin(actor)
  def update(actor, _feed), do: is_admin(actor)
  def refresh(actor, feed), do: update(actor, feed)
  def delete(actor, _feed), do: is_admin(actor)
end
