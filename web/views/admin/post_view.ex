defmodule Changelog.Admin.PostView do
  use Changelog.Web, :view

  import Changelog.Admin.SharedView, only: :functions
  import Scrivener.HTML

  alias Changelog.Post

  def status_label(post) do
    if post.published do
      content_tag :span, "Published", class: "ui tiny green basic label"
    else
      content_tag :span, "Draft", class: "ui tiny yellow basic label"
    end
  end

  def show_or_preview(post) do
    if Post.is_public(post) do
      :show
    else
      :preview
    end
  end
end
