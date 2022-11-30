defmodule ChangelogWeb.Meta do
  @doc """
  Phoenix used to provide us :view_module and :view_template in the `assigns`
  map, but as of 1.6 it no longer does. Instead of rewriting every function in
  our Meta modules, we use this function to merge those keys back in to the
  assigns and call this from those modules prior to the existing functions.

  Each sub-module now has one public function: `get/1`` or `get/2` which
  implements said behavior.
  """
  def prep_assigns(conn) do
    view = Phoenix.Controller.view_module(conn)
    template = Phoenix.Controller.view_template(conn)
    Map.merge(conn.assigns, %{view_module: view, view_template: template})
  end
end
