defmodule Changelog.SearchPolicy do
  use Changelog.DefaultPolicy

  def all(actor), do: is_admin(actor)
  def one(actor), do: is_admin(actor)
end
