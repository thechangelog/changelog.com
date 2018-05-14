defmodule Changelog.DefaultPolicy do
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

      defp is_host(nil), do: false
      defp is_host(actor), do: Map.get(actor, :host, false)

      defoverridable [new: 1, create: 1, index: 1, show: 2, edit: 2, update: 2, delete: 2]
    end
  end
end
