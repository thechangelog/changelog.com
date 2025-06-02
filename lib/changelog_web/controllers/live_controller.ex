defmodule ChangelogWeb.LiveController do
  use ChangelogWeb, :controller

  def show(conn, _params) do
    redirect(conn, to: ~p"/live")
  end

  def ical(conn, _params) do
    conn
    |> put_status(410)
    |> text("This calendar feed has been discontinued.")
  end
end
