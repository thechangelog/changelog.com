defmodule ChangelogWeb.Meta.AdminTitle do

  alias ChangelogWeb.Admin.{PageView, PersonView}

  @suffix "Changelog Admin"

  def admin_page_title(assigns), do: assigns |> get |> put_suffix

  defp put_suffix(nil), do: @suffix
  defp put_suffix(title), do: "#{title} |> #{@suffix}"

  defp get(%{view_module: PageView}), do: nil
  defp get(%{view_module: PersonView, view_template: template}) do
    "People |> #{get_template_name(template)}"
  end
  defp get(%{view_module: view, view_template: template}) do
    "#{get_view_name(view)}s |> #{get_template_name(template)}"
  end

  defp get(_), do: nil

  defp get_view_name(view) do
    view
    |> Module.split
    |> List.last
    |> String.replace("View", "")
  end

  defp get_template_name(template) do
    template
    |> String.replace(".html", "")
    |> String.capitalize
  end
end
