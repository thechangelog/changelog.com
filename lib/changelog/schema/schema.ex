defmodule Changelog.Schema do
  defmacro __using__(opts) do
    opts = Keyword.merge([default_sort: :inserted_at], opts)

    quote do
      use Ecto.Schema
      use Waffle.Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
      import EctoEnum, only: [defenum: 2]

      alias Changelog.{Hashid, Repo}

      def any?(query), do: Repo.count(query) > 0

      def by_position(query \\ __MODULE__), do: from(q in query, order_by: q.position)
      def limit(query \\ __MODULE__, count), do: from(q in query, limit: ^count)

      def newest_first(query \\ __MODULE__, field \\ unquote(opts[:default_sort])),
        do: from(q in query, order_by: [desc: ^field])

      def newest_last(query \\ __MODULE__, field \\ unquote(opts[:default_sort])),
        do: from(q in query, order_by: [asc: ^field])

      def newer_than(query \\ __MODULE__, date_or_time, field \\ unquote(opts[:default_sort]))

      def newer_than(query, nil, _field), do: query

      def newer_than(query, date = %Date{}, field),
        do: from(q in query, where: field(q, ^field) > ^Timex.to_datetime(date))

      def newer_than(query, time = %DateTime{}, field),
        do: from(q in query, where: field(q, ^field) > ^time)

      def older_than(query \\ __MODULE__, date_or_time, field \\ unquote(opts[:default_sort]))

      def older_than(query, nil, _field), do: query

      def older_than(query, date = %Date{}, field),
        do: from(q in query, where: field(q, ^field) < ^Timex.to_datetime(date))

      def older_than(query, time = %DateTime{}, field),
        do: from(q in query, where: field(q, ^field) < ^time)

      def with_ids(query \\ __MODULE__, ids, id_field \\ :id) do
        from(q in query, where: field(q, ^id_field) in ^ids)
      end

      def decode(hashid) when is_binary(hashid), do: Hashid.decode(hashid)
      # sentinal query value
      def decode(_), do: -1

      def hashid(id) when is_integer(id), do: Hashid.encode(id)
      def hashid(struct), do: hashid(struct.id)

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
