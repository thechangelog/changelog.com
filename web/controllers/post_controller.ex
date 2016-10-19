defmodule Changelog.PostController do
  use Changelog.Web, :controller

  alias Changelog.Post

  plug Changelog.Plug.RequireAdmin, "before preview" when action in [:preview]

  def show(conn, %{"id" => slug}) do
    post = Repo.get_by!(Post, slug: slug, published: true) |> Post.preload_all
    render conn, "show.html", post: post
  end

  def preview(conn, %{"id" => slug}) do
    post = Repo.get_by!(Post, slug: slug) |> Post.preload_all
    render conn, "show.html", post: post
  end
end
