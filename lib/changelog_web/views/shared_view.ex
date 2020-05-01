defmodule ChangelogWeb.SharedView do
  use ChangelogWeb, :public_view

  def pagination_path(offset, %{conn: conn, page: page, query: q}) do
    current_path(conn, %{q: q, page: page.page_number + offset})
  end

  def pagination_path(offset, %{conn: conn, page: page}) do
    current_path(conn, %{page: page.page_number + offset})
  end
end
