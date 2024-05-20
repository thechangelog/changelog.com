defmodule ChangelogWeb.Admin.EventLogController do
  use ChangelogWeb, :controller

  alias Changelog.{EventLog}

  plug :assign_event when action in [:delete]
  plug Authorize, [Policies.AdminsOnly, :event]

  def index(conn, params) do
    page =
      EventLog
      |> EventLog.newest_first()
      |> Repo.paginate(Map.put(params, :page_size, 100))

    conn
    |> assign(:events, page.entries)
    |> assign(:page, page)
    |> render(:index)
  end

  def delete(conn = %{assigns: %{event: event}}, _params) do
    Repo.delete!(event)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: ~p"/admin/events")
  end

  defp assign_event(conn = %{params: %{"id" => id}}, _) do
    event = Repo.get(EventLog, id)
    assign(conn, :event, event)
  end
end
