defmodule Changelog.Policies.Admin.Membership do
  use Changelog.Policies.Default

  def index(actor), do: is_admin(actor)
  def show(actor, _), do: is_admin(actor)
  def update(actor, _), do: is_admin(actor)
  def refresh(actor), do: is_admin(actor)
end
