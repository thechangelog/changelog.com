defmodule Changelog.Data do
  defmacro __using__(opts) do
    opts = Keyword.merge([default_sort: :inserted_at], opts)

    quote do
      use Ecto.Schema
      use Changelog.Arc.Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
      import EctoEnum, only: [defenum: 2]

      alias Changelog.Repo

      def by_position(query \\ __MODULE__), do: from(q in query, order_by: q.position)
      def limit(query \\ __MODULE__, count), do: from(q in query, limit: ^count)
      def newest_first(query \\ __MODULE__, field \\ unquote(opts[:default_sort])), do: from(q in query, order_by: [desc: ^field])
      def newest_last(query \\ __MODULE__, field \\ unquote(opts[:default_sort])), do: from(q in query, order_by: [asc: ^field])

      defp mark_for_deletion(changeset) do
        if get_change(changeset, :delete) do
          %{changeset | action: :delete}
        else
          changeset
        end
      end

      defp now_in_seconds, do: Timex.now() |> DateTime.truncate(:second)
    end
  end
end
