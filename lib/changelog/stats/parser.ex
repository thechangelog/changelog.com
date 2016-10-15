defmodule Changelog.Stats.Parser do
  alias NimbleCSV.RFC4180, as: CSV
  alias Changelog.Stats.Entry

  # e.g. – <134>2016-10-13T18:09:07Z cache-fra1237 S3TheChangelog[415970]:
  @prefix_regex ~r/^\<\d+\>\d{4}-\d{2}-\d{2}\w\d{2}:\d{2}:\d{2}\w .*?:\s/

  def parse_files(files) do
    files
    |> Enum.map(&parse_file/1)
    |> List.flatten
  end

  def parse_file(file) do
    file
    |> File.read!
    |> String.split("\n")
    |> Enum.reject(fn(x) -> String.length(x) == 0 end)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    values = line
    |> String.replace(@prefix_regex, "")
    |> CSV.parse_string(headers: false)
    |> List.first

    %Entry{
      ip: get_ip(values),
      episode: get_episode(values),
      bytes: get_bytes(values),
      status: get_status(values),
      agent: get_agent(values),
      latitude: get_latitude(values),
      longitude: get_longitude(values),
      city_name: get_city_name(values),
      continent_code: get_continent_code(values),
      country_code: get_country_code(values),
      country_name: get_country_name(values)
    }
  end

  defp get_ip(list), do: Enum.at(list, 0)
  defp get_episode(list), do: Enum.at(list, 2) |> String.split("/") |> Enum.at(3)
  defp get_bytes(list), do: Enum.at(list, 3) |> String.to_integer
  defp get_status(list), do: Enum.at(list, 4) |> String.to_integer
  defp get_agent(list), do: Enum.at(list, 5)
  defp get_latitude(list), do: Enum.at(list, 6) |> String.to_float
  defp get_longitude(list), do: Enum.at(list, 7) |> String.to_float
  defp get_city_name(list), do: Enum.at(list, 8) |> get_city_name_with_default
  defp get_city_name_with_default("(null)"), do: "Unknown"
  defp get_city_name_with_default(name), do: name
  defp get_continent_code(list), do: Enum.at(list, 9)
  defp get_country_code(list), do: Enum.at(list, 10)
  defp get_country_name(list), do: Enum.at(list, 11)
end
