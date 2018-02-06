defmodule ChangelogWeb.Meta.Twitter do
  def twitter_card_type(assigns), do: assigns |> get

  defp get(_), do: "summary"
end
