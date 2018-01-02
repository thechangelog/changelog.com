defmodule ChangelogWeb.PostController do
  use ChangelogWeb, :controller

  alias Changelog.Post

  plug RequireAdmin, "before preview" when action in [:preview]

  def index(conn, params) do
    page =
      Post.published
      |> Post.newest_first
      |> preload(:author)
      |> Repo.paginate(Map.put(params, :page_size, 15))

    render(conn, :index, posts: page.entries, page: page)
  end

  def show(conn, %{"id" => slug}) do
    post =
      Post.published
      |> Repo.get_by!(slug: slug)
      |> Post.preload_all

    render(conn, :show, post: post)
  end

  def preview(conn, %{"id" => slug}) do
    post = Repo.get_by!(Post, slug: slug) |> Post.preload_all
    render(conn, :show, post: post)
  end
end
