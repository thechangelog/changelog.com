defmodule Changelog.SearchController do
  use Changelog.Web, :controller

  alias Changelog.{Episode}

  require Logger

  def search(conn, params) do
    case params do
      %{"q" => query} ->
        episodes =
          Episode
          |> Episode.published
          |> Episode.search(query)
          |> Episode.newest_first
          |> Episode.limit(10)
          |> Repo.all
          |> Episode.preload_podcast
          |> Episode.preload_guests

        results = %{
          episodes: episodes
        }

        render(conn, "search.html", query: query, results: results)

      _else ->
        render(conn, "search.html", query: nil, results: nil)
    end
  end
end
