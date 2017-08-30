defmodule ChangelogWeb.Meta.Twitter do

  alias ChangelogWeb.{PageView}

  def twitter_card_type(assigns), do: assigns |> get

  defp get(%{view_module: PageView, view_template: "home.html"}), do: "summary_large_image"
  defp get(_), do: "summary"
end
