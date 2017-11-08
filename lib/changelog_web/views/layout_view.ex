defmodule ChangelogWeb.LayoutView do
  use ChangelogWeb, :public_view

  import ChangelogWeb.Meta.{AdminTitle, Title, Image, Description, Feeds, Twitter}

  alias ChangelogWeb.{Endpoint, LiveView, PersonView}

  def active_class(conn, controllers) when is_list(controllers) do
    active_controller =
      Phoenix.Controller.controller_module(conn)
      |> Module.split
      |> List.last
      |> String.replace("Controller", "")

    if Enum.member?(controllers, active_controller) do
      "active"
    else
      ""
    end
  end

  def active_class(conn, controllers) do
    active_class(conn, [controllers])
  end

  def body_class(%{view_module: LiveView}), do: "page-live"
  def body_class(_), do: ""

  def canonical_url(conn) do
    url(conn) <> conn.request_path
  end
end
