defmodule ChangelogWeb.PostView do
  use ChangelogWeb, :public_view

  alias ChangelogWeb.{NewsItemView, PersonView}

  def admin_edit_link(conn, user, post) do
    if user && user.admin do
      link("[Edit]", to: admin_post_path(conn, :edit, post, next: current_path(conn)), data: [turbolinks: false])
    end
  end

  def guid(post) do
    post.guid || "changelog.com/posts/#{post.id}"
  end
end
