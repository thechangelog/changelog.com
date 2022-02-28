defmodule Changelog.Policies.Admin.Page do
  use Changelog.Policies.Default

  def index(actor), do: is_admin(actor) || is_editor(actor) || is_host(actor)
  def fresh_requests(actor), do: is_admin(actor)
  def purge(actor), do: is_admin(actor)
  def downloads(actor), do: is_admin(actor)
end
