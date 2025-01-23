defmodule Changelog.Kits.MarkerKit do
  alias ChangelogWeb.TimeView
  NimbleCSV.define(CsvParser, separator: "\t", escape: "\\")

  # Name	Start	Duration	Time Format	Type	Description
  def to_youtube(string) do
    string
    |> CsvParser.parse_string()
    |> Enum.map(fn [name, start | _] -> "#{duration(start)} #{name}" end)
    |> Enum.join("\n")
  end

  # Converting to seconds and back removes decimals and extra padding
  defp duration(start) do
    start |> TimeView.seconds() |> TimeView.duration()
  end
end
