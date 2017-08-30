defmodule ChangelogWeb.PostView do
  use ChangelogWeb, :public_view

  alias ChangelogWeb.{PersonView, SharedView}

  def guid(post) do
    post.guid || "changelog.com/posts/#{post.id}"
  end
end
