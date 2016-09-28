defmodule Changelog.PostView do
  use Changelog.Web, :view

  alias Changelog.PersonView

  def guid(post) do
    "changelog.com/posts/#{post.id}"
  end
end
