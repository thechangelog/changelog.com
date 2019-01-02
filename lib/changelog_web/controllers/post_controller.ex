defmodule ChangelogWeb.PostController do
  use ChangelogWeb, :controller

  alias Changelog.{Post, NewsItem, NewsItemComment}

  plug PublicEtsCache

  def index(conn, params) do
    page =
      NewsItem.published()
      |> NewsItem.with_object_prefix("post")
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.paginate(Map.put(params, :page_size, 15))

    items = Enum.map(page.entries, &NewsItem.load_object/1)

    conn
    |> assign(:page, page)
    |> assign(:items, items)
    |> render(:index)
  end

  def show(conn, %{"id" => slug}) do
    post =
      Post.published
      |> Post.preload_all()
      |> Repo.get_by!(slug: slug)
      |> Post.load_news_item()

    item =
      post.news_item
      |> NewsItem.preload_all()
      |> NewsItem.preload_comments()

    conn = if item do
      conn
      |> assign(:comments, NewsItemComment.nested(item.comments))
      |> assign(:changeset, item |> build_assoc(:comments) |> NewsItemComment.insert_changeset())
    else
      conn
    end

    conn
    |> assign(:post, post)
    |> assign(:item, item)
    |> render(:show)
  end

  def preview(conn, %{"id" => id}) do
    post = Repo.get!(Post, id) |> Post.preload_all()
    conn
    |> assign(:post, post)
    |> assign(:item, nil)
    |> render(:show)
  end
end
