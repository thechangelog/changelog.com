defmodule ChangelogWeb.PostView do
  use ChangelogWeb, :public_view

  alias ChangelogWeb.{PersonView}

  def admin_edit_link(conn, user, post) do
    if user && user.admin do
      link("[Edit]", to: admin_post_path(conn, :edit, post), data: [turbolinks: false])
    end
  end

  def guid(post) do
    post.guid || "changelog.com/posts/#{post.id}"
  end
end
