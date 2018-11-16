defmodule Changelog.Repo do
  use Ecto.Repo, otp_app: :changelog, adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 25

  require Ecto.Query

  def count(query) do
    one(Ecto.Query.from(r in query, select: count(r.id)))
  end
end
