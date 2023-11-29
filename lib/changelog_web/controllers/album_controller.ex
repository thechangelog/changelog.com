defmodule ChangelogWeb.AlbumController do
  use ChangelogWeb, :controller

  alias Changelog.{Album}

  def index(conn, _params) do
    conn
    |> assign(:albums, Album.all())
    |> render(:index)
  end

  def show(conn, %{"slug" => slug}) do
    if album = Album.get_by_slug(slug) do
      conn
      |> assign(:album, album)
      |> render(:show)
    else
      send_resp(conn, :not_found, "")
    end
  end
end
