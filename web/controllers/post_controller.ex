defmodule Changelog.PostController do
  use Changelog.Web, :controller

  alias Changelog.Post

  def show(conn, %{"id" => slug}) do
    post = Repo.get_by!(Post, slug: slug, published: true) |> Post.preload_all
    render conn, "show.html", post: post
  end
end
