defmodule Changelog.Policies.Default do
  defmacro __using__(_opts) do
    quote do
      def new(actor), do: create(actor)
      def create(_actor), do: false

      def index(_actor), do: false
      def show(_actor, _resource), do: false

      def edit(resource, actor), do: update(resource, actor)
      def update(_actor, _resource), do: false

      def delete(_actor, _resource), do: false

      defp is_admin(nil), do: false
      defp is_admin(actor), do: Map.get(actor, :admin, false)

      defp is_editor(nil), do: false
      defp is_editor(actor), do: Map.get(actor, :editor, false)

      defp is_host(nil), do: false
      defp is_host(actor), do: Map.get(actor, :host, false)

      defp is_admin_or_editor(nil), do: false
      defp is_admin_or_editor(actor), do: is_admin(actor) || is_editor(actor)

      defp is_admin_or_host(nil), do: false
      defp is_admin_or_host(actor), do: is_admin(actor) || is_host(actor)

      defp is_admin_editor_or_host(nil), do: false
      defp is_admin_editor_or_host(actor), do: is_admin_or_host(actor) || is_editor(actor)

      defoverridable [new: 1, create: 1, index: 1, show: 2, edit: 2, update: 2, delete: 2]
    end
  end
end
