defmodule Changelog.PostController do
  use Changelog.Web, :controller

  alias Changelog.Post

  def show(conn, %{"id" => slug}) do
    post = Repo.get_by!(Post, slug: slug, published: true) |> Post.preload_all
    render conn, "show.html", post: post
  end

  def feed(conn, _params) do
    posts =
      Post.published
      |> Post.newest_first
      |> Repo.all
      |> Post.preload_author

    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("feed.xml", posts: posts)
  end
end
