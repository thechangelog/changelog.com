defmodule Changelog.Policies.Search do
  use Changelog.Policies.Default

  def all(actor), do: is_admin(actor)
  def all(actor, _), do: is_admin(actor)
  def one(actor), do: is_admin(actor)
  def one(actor, "news_source"), do: is_admin_editor_or_host(actor)
  def one(actor, "person"), do: is_admin_editor_or_host(actor)
  def one(actor, "topic"), do: is_admin_editor_or_host(actor)
  def one(actor, _), do: is_admin(actor)
end
