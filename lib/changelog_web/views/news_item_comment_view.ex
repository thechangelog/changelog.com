defmodule ChangelogWeb.NewsItemCommentView do
  use ChangelogWeb, :public_view

  alias Changelog.{ListKit, HtmlKit, NewsItemComment, StringKit}
  alias ChangelogWeb.{LayoutView, PersonView, TimeView}

  def hashid(comment), do: NewsItemComment.hashid(comment)

  def modifier_classes(item, comment) do
    [
      if(Enum.any?(comment.children), do: "comment--has_replies"),
      if(item.author_id == comment.author_id, do: "is-author")
    ]
    |> ListKit.compact_join()
  end

  def permalink_path(comment), do: "#comment-#{hashid(comment)}"

  def transformed_content(content) do
    mentioned = NewsItemComment.mentioned_people(content)

    content
    |> StringKit.mentions_linkify(mentioned)
    |> StringKit.md_linkify()
    |> SharedHelpers.md_to_safe_html()
    |> HtmlKit.put_ugc()
  end
end
