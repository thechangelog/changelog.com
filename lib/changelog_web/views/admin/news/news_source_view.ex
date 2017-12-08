defmodule ChangelogWeb.Admin.NewsSourceView do
  use ChangelogWeb, :admin_view

  alias ChangelogWeb.NewsSourceView

  def icon_url(source), do: NewsSourceView.icon_url(source)
end
