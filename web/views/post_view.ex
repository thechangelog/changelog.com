defmodule Changelog.PostView do
  use Changelog.Web, :public_view

  alias Changelog.PersonView

  def guid(post) do
    post.guid || "changelog.com/posts/#{post.id}"
  end
end
