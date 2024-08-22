defmodule ChangelogWeb.Admin.PostView do
  use ChangelogWeb, :admin_view

  alias Changelog.{Post, Topic}
  alias ChangelogWeb.PostView
  alias ChangelogWeb.Admin.SharedView

  def image_url(post, version), do: PostView.image_url(post, version)

  def status_label(post) do
    if post.published do
      content_tag(:span, "Published", class: "ui tiny green basic label")
    else
      content_tag(:span, "Draft", class: "ui tiny yellow basic label")
    end
  end

  def show_or_preview_path(conn, post) do
    if Post.is_public(post) do
      Routes.post_path(conn, :show, post.slug)
    else
      Routes.post_path(conn, :preview, Post.hashid(post))
    end
  end
end
