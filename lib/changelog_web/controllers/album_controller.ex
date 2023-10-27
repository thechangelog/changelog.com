defmodule ChangelogWeb.AlbumController do
  use ChangelogWeb, :controller

  alias Changelog.{Album}

  def index(conn, _params) do
    conn
    |> assign(:albums, Album.all())
    |> render(:index)
  end

  def show(conn, %{"slug" => slug}) do
    album = Album.get_by_slug(slug)

    conn
    |> assign(:album, album)
    |> render(:show)
  end
end
