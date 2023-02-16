defmodule Mix.Tasks.Changelog.Typesense do
  use Mix.Task

  require Logger

  alias Changelog.{NewsItem, Repo, TypesenseSearch}

  @shortdoc "Indexes all the things in Typesense"

  def run(_) do
    Mix.Task.run("app.start")

    items =
      NewsItem
      |> NewsItem.published()
      |> NewsItem.non_feed_only()
      |> NewsItem.newest_last()
      |> Repo.all()

    TypesenseSearch.create_collection()

    for items_chunk <- Enum.chunk_every(items, 100) do
      Enum.each(items_chunk, fn item -> IO.puts("Indexing ##{item.id} - #{item.headline}") end)
      TypesenseSearch.save_items(items_chunk)
    end
  end
end
