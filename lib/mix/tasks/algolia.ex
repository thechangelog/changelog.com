defmodule Mix.Tasks.Changelog.Algolia do
  use Mix.Task

  alias Changelog.{NewsItem, Repo, Search}

  @shortdoc "Indexes all the things"

  def run(_) do
    Mix.Task.run("app.start")

    items =
      NewsItem
      |> NewsItem.published()
      |> NewsItem.non_feed_only()
      |> NewsItem.newest_last()
      |> Repo.all()

    for item <- items do
      IO.puts("indexing ##{item.id} - #{item.headline}")
      Search.save_item(item)
    end
  end
end
