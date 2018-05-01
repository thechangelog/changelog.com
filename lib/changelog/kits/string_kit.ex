defmodule Changelog.StringKit do
  def dasherize(string) do
    string
    |> String.downcase
    |> String.replace(~r/[^\w\s]/, "")
    |> String.replace(" ", "-")
  end
end
