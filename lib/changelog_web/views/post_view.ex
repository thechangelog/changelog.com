defmodule ChangelogWeb.PostView do
  use ChangelogWeb, :public_view

  alias Changelog.{Files, ListKit}
  alias ChangelogWeb.{Endpoint, NewsItemView, PersonView}

  def admin_edit_link(conn, %{admin: true}, post) do
    path = Routes.admin_post_path(conn, :edit, post, next: SharedHelpers.current_path(conn))
    link("[edit]", to: path)
  end

  def admin_edit_link(_, _, _), do: nil

  def guid(post), do: post.guid || "changelog.com/posts/#{post.id}"

  def image_mime_type(post), do: Files.Image.mime_type(post.image)

  def image_url(post, version), do: Files.Image.url({post.image, post}, version)

  def paragraph_count(post) do
    post
    |> Map.get(:body, "")
    |> SharedHelpers.md_to_html()
    |> String.split("<p>")
    |> ListKit.compact()
    |> length()
  end

  def url(post, action \\ :show), do: Routes.post_url(Endpoint, action, post.slug)
end
