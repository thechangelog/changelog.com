defmodule Changelog.AdminPolicy do
  use Changelog.DefaultPolicy

  def index(actor), do: is_admin(actor) || is_editor(actor) || is_host(actor)
end
