defmodule ChangelogWeb.LayoutView do
  use ChangelogWeb, :public_view

  import ChangelogWeb.Meta.{AdminTitle, Title, Image, Description, Feeds, Twitter}

  alias ChangelogWeb.{Endpoint, LiveView, PersonView, PodcastView, SharedView}
  alias Phoenix.{Controller, Naming}

  def active_class(conn, controllers) when is_list(controllers) do
    active_controller = controller_name(conn)

    if Enum.member?(controllers, active_controller) do
      "active"
    else
      ""
    end
  end
  def active_class(conn, controllers) do
    active_class(conn, [controllers])
  end

  def action_name(conn) do
    Controller.action_name(conn)
  end

  def canonical_url(conn) do
    url(conn) <> conn.request_path
  end

  def controller_name(conn) do
    Controller.controller_module(conn) |> Naming.resource_name("Controller")
  end
end
