defmodule Changelog.Policies.Admin do
  use Changelog.Policies.Default

  def index(actor), do: is_admin(actor) || is_editor(actor) || is_host(actor)
end
