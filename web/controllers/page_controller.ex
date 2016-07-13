defmodule Changelog.PageController do
  use Changelog.Web, :controller

  alias Changelog.Podcast

  plug :load_podcasts

  def index(conn, _params) do
    render(conn, "index.html")
  end

  defp load_podcasts(conn, _params) do
    podcasts = Repo.all(Podcast)
    assign(conn, :podcasts, podcasts)
  end
end
