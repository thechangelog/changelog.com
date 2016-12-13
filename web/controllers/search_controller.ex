defmodule Changelog.SearchController do
  use Changelog.Web, :controller

  # alias Changelog.{Episode, Podcast, Post}

  require Logger

  # TODO: Cases when there is …
  # - no query
  # - a query and results
  # - a query and no results
  def search(conn, params) do
    query = params["q"]
    render(conn, "search.html", query: query)
  end
end
