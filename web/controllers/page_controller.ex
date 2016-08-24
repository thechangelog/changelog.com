defmodule Changelog.PageController do
  use Changelog.Web, :controller

  alias Changelog.Episode

  # pages that need special treatment get their own matched function
  # all others simply render the template of the same name
  def action(conn, params) do
    case action_name(conn) do
      :home -> home(conn, params)
      action -> render(conn, action)
    end
  end

  def home(conn, _params) do
    featured =
      Episode.published
      |> Episode.featured
      |> Episode.newest_first
      |> Episode.limit(1)
      |> Repo.all
      |> Episode.preload_podcast
      |> Episode.preload_sponsors

    render(conn, :home, featured: featured)
  end
end
