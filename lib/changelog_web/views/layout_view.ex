defmodule ChangelogWeb.LayoutView do
  use ChangelogWeb, :public_view

  import ChangelogWeb.Meta.{AdminTitle, Title, Image, Description, Feeds, Twitter}

  alias ChangelogWeb.{Endpoint, LiveView, PersonView, PodcastView, SharedView}
  alias Phoenix.{Controller, Naming}

  def active_class(conn, controllers, class_name \\ "is-active")
  def active_class(conn, controllers, class_name) when is_binary(controllers), do: active_class(conn, [controllers], class_name)
  def active_class(conn, controllers, class_name) when is_list(controllers) do
    active_id = controller_action_combo(conn)

    if Enum.any?(controllers, fn(x) -> String.match?(active_id, ~r/#{x}/) end) do
      class_name
    end
  end

  def action_name(conn), do: Controller.action_name(conn)
  def canonical_url(conn), do: url(conn) <> conn.request_path
  def controller_name(conn), do: Controller.controller_module(conn) |> Naming.resource_name("Controller")
  def controller_action_combo(conn), do: [controller_name(conn), action_name(conn)] |> Enum.join("-")
end
