# Sub policy is based on owner item/podcast, which is always available
defmodule Changelog.Policies.Admin.Subscription do
  use Changelog.Policies.Default

  def index(actor, _item_or_podcast), do: is_admin(actor)
  def import(actor, _item_or_podcast), do: is_admin(actor)
end
