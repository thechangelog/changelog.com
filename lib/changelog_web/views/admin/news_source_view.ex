defmodule ChangelogWeb.Admin.NewsSourceView do
  use ChangelogWeb, :admin_view

  alias ChangelogWeb.NewsSourceView
  alias ChangelogWeb.Admin.SharedView

  def icon_url(source), do: NewsSourceView.icon_url(source)
end
