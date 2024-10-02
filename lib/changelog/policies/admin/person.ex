defmodule Changelog.Policies.Admin.Person do
  use Changelog.Policies.Default

  def create(actor), do: is_admin_editor_or_host(actor)
  def index(actor), do: is_admin_editor_or_host(actor)
  def show(actor, _), do: is_admin_editor_or_host(actor)
  def update(actor, _), do: is_admin_editor_or_host(actor)
  def delete(actor, _), do: is_admin(actor)
  def roles(actor, _), do: is_admin(actor)

  # extra actions
  def news(actor, context), do: show(actor, context)
  def comments(actor, context), do: show(actor, context)
  def slack(actor, _), do: is_admin_editor_or_host(actor)
  def zulip(actor, _), do: is_admin_editor_or_host(actor)
  def masq(actor, _), do: is_admin(actor)
end
