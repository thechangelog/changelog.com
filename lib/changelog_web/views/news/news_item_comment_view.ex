defmodule ChangelogWeb.NewsItemCommentView do
  use ChangelogWeb, :public_view

  alias Changelog.{Hashid, NewsItemComment, StringKit}
  alias ChangelogWeb.{LayoutView, PersonView, TimeView}

  def hashid(id) when is_integer(id), do: Hashid.encode(id)
  def hashid(comment = %NewsItemComment{}), do: Hashid.encode(comment.id)

  def modifier_classes(item, comment) do
    [(if Enum.any?(comment.children), do: "comment--has_replies"),
      (if item.author_id == comment.author_id, do: "is-author")]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  def permalink_path(comment), do: "#comment-#{hashid(comment)}"

  def transformed_content(content) do
    content |> StringKit.md_linkify() |> md_to_safe_html()
  end
end
