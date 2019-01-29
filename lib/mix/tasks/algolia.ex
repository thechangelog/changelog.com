defmodule Mix.Tasks.Changelog.Algolia do
  use Mix.Task

  alias Changelog.{NewsItem, Repo, Search}

  @shortdoc "Indexes all the things"

  def run(_) do
    Mix.Task.run "app.start"
    items = Repo.all(NewsItem.newest_last(NewsItem.published))
    for item <- items do
      IO.puts "indexing ##{item.id} - #{item.headline}"
      Search.update_item(item)
    end
  end
end
