defmodule ChangelogWeb.NewsItemCommentView do
  use ChangelogWeb, :public_view

  alias Changelog.Hashid
  alias ChangelogWeb.{PersonView, TimeView}

  def modifier_classes(item, comment) do
    [(if Enum.any?(comment.children), do: "comment--has_replies"),
      (if item.author_id == comment.author_id, do: "is-author")]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  def hashid(comment), do: Hashid.encode(comment.id)
end
