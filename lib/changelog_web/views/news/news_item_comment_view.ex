defmodule ChangelogWeb.NewsItemCommentView do
  use ChangelogWeb, :public_view

  alias Changelog.Hashid
  alias ChangelogWeb.PersonView

  def hashid(comment), do: Hashid.encode(comment.id)
end
