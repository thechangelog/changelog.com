defmodule ChangelogWeb.HomeView do
  use ChangelogWeb, :public_view

  alias ChangelogWeb.{SharedView, PersonView}

  # TODO: This is a duplicate from Layout View
  def active_class(conn, controllers) when is_list(controllers) do
    active_controller =
      Phoenix.Controller.controller_module(conn)
      |> Module.split
      |> List.last
      |> String.replace("Controller", "")

    if Enum.member?(controllers, active_controller) do
      "active"
    else
      "df"
    end
  end

  def active_class(conn, controllers) do
    active_class(conn, [controllers])
  end

  def checked_class_if(boolean) do
    if boolean do
      "checklist-item--checked"
    end
  end
end
