defmodule Changelog.Admin.PostView do
  use Changelog.Web, :view

  import Changelog.Admin.SharedView
  import Scrivener.HTML

  def status_label(post) do
    if post.published do
      content_tag :span, "Published", class: "ui tiny green label"
    else
      content_tag :span, "Draft", class: "ui tiny yellow label"
    end
  end
end
