defmodule ChangelogWeb.Meta.AdminTitle do
  alias ChangelogWeb.Meta
  alias ChangelogWeb.Admin.{EpisodeView, PageView, PersonView}

  @suffix "Admin"

  def get(conn) do
    assigns = Meta.prep_assigns(conn)
    assigns |> title() |> put_suffix()
  end

  defp put_suffix(nil), do: @suffix
  defp put_suffix(title), do: "#{title} |> #{@suffix}"

  defp title(%{view_module: EpisodeView, view_template: template, podcast: podcast}) do
    "#{podcast.name} |> Episodes |> #{get_template_name(template)}"
  end

  defp title(%{view_module: PageView}), do: nil

  defp title(%{view_module: PersonView, view_template: template}) do
    "People |> #{get_template_name(template)}"
  end

  defp title(%{view_module: view, view_template: template}) do
    "#{get_view_name(view)}s |> #{get_template_name(template)}"
  end

  defp title(_), do: nil

  defp get_view_name(view) do
    view
    |> Module.split()
    |> List.last()
    |> String.replace("View", "")
    |> String.split(~r/(?=[A-Z])/)
    |> Enum.join(" ")
  end

  defp get_template_name(template) do
    template
    |> String.replace(".html", "")
    |> String.capitalize()
  end
end
