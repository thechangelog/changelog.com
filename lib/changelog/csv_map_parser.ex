defmodule Changelog.CsvMapParser do
  @moduledoc """
  Parses standard CSV files and returns List of Maps
  """
  alias Changelog.StringKit
  alias NimbleCSV.RFC4180, as: CSV

  def parse_file(%{path: path}), do: parse_file(path)

  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> parse_string()
  end

  def parse_string(string) do
    string
    |> CSV.parse_string(skip_headers: false)
    |> csv_to_maps()
  end

  defp csv_to_maps([headers | rows]) do
    headers = Enum.map(headers, &String.trim/1)

    Enum.map(rows, fn row ->
      headers
      |> Enum.zip(row)
      |> Map.new(fn {key, value} -> {StringKit.snake_case(key), String.trim(value)} end)
    end)
  end

  defp csv_to_maps([]), do: []
end
