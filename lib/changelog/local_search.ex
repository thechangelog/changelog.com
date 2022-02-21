defmodule Changelog.LocalSearch do
  alias Changelog.{NewsItem, Repo}

  def search(query, opts) do
    page =
      NewsItem
      |> NewsItem.published()
      |> NewsItem.search(query)
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.paginate(%{page_size: opts[:hitsPerPage], page_number: opts[:page]})

    items = Enum.map(page.entries, &NewsItem.load_object/1)

     Map.merge(page, %{entries: items})
  end

  # this is effectively a no-op since we aren't returning highlights from our
  # search queries, so we simply wrap each entry in a tuple with a nil highlight
  def search_with_highlights(query, opts) do
    page = search(query, opts)
    with_highlights = Enum.map(page.entries, &({&1, nil}))
    Map.merge(page, %{entries: with_highlights})
  end
end
