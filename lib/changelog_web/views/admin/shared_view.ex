defmodule ChangelogWeb.Admin.SharedView do
  use ChangelogWeb, :admin_view

  def pagination_link_classes(paginator, page_number) do
    if paginator.page_number == page_number do
      "active item"
    else
      "item"
    end
  end


  @doc"""
    Constructs a pagination path for the given page, extracting relevant
    path params [filter, action] from the connection to construct said path
  """
  def pagination_path(conn, page) do
    scopes = [:filter, :action]
    params = Map.merge(%{page: page}, Map.take(conn.assigns, scopes))
    SharedHelpers.current_path(conn, params)
  end
end
