defmodule Changelog.LayoutView do
  use Changelog.Web, :public_view

  import Changelog.Meta.{AdminTitle, Title, Image, Description, Feeds, Twitter}

  alias Changelog.{Endpoint, LiveView, PersonView}

  def active_class(conn, controllers) when is_list(controllers) do
    if Enum.member?(controllers, Phoenix.Controller.controller_module(conn)) do
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
