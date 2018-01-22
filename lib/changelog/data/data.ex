defmodule Changelog.Data do
  defmacro __using__(opts) do
    opts = Keyword.merge([default_sort: :inserted_at], opts)

    quote do
      use Ecto.Schema
      use Changelog.Arc.Ecto.Schema
      use Timex.Ecto.Timestamps

      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
      import EctoEnum, only: [defenum: 2]

      alias Changelog.Repo

      def limit(query \\ __MODULE__, count), do: from(q in query, limit: ^count)
      def newest_first(query \\ __MODULE__, field \\ unquote(opts[:default_sort])), do: from(q in query, order_by: [desc: ^field])
      def newest_last(query \\ __MODULE__, field \\ unquote(opts[:default_sort])), do: from(q in query, order_by: [asc: ^field])
    end
  end
end
