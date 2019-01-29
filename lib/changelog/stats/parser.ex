defmodule Changelog.Stats.Parser do
  alias NimbleCSV.RFC4180, as: CSV
  alias Changelog.Stats.Entry

  require Logger

  # e.g. – <134>2016-10-13T18:09:07Z cache-fra1237 S3TheChangelog[415970]:
  @prefix_regex ~r/^\<\d+\>\d{4}-\d{2}-\d{2}\w\d{2}:\d{2}:\d{2}\w .*?:\s/
  # e.g. – ,""user agent"", but not ,"",
  @double_double_quotes_regex ~r/\"\"\b|\b\"\"/

  def parse(logs) when is_list(logs), do: Enum.flat_map(logs, &parse/1)
  def parse(log) when is_binary(log) do
    log
    |> String.split("\n")
    |> Enum.reject(fn(x) -> String.length(x) == 0 end)
    |> Enum.map(&parse_line/1)
    |> Enum.reject(&useless_entry/1)
  end

  def parse_line(line) do
    try do
      values = line
      |> String.replace(@prefix_regex, "")
      |> String.replace(@double_double_quotes_regex, "\"")
      |> CSV.parse_string(headers: false)
      |> List.first

      %Entry{ip: get_ip(values),
             episode: get_episode(values),
             bytes: get_bytes(values),
             status: get_status(values),
             agent: get_agent(values),
             latitude: get_latitude(values),
             longitude: get_longitude(values),
             city_name: get_city_name(values),
             continent_code: get_continent_code(values),
             country_code: get_country_code(values),
             country_name: get_country_name(values)}
    rescue
      exception ->
        Logger.info("Stats: Parse Error '#{exception.message}'\n#{line}")
        Rollbax.report(:error, exception, System.stacktrace(), %{line: line})
        %Entry{bytes: 0}
    end
  end

  defp get_ip(list), do: Enum.at(list, 0)
  defp get_episode(list), do: Enum.at(list, 2) |> String.split("/") |> Enum.at(3)
  defp get_bytes(list), do: Enum.at(list, 3) |> String.to_integer
  defp get_status(list), do: Enum.at(list, 4) |> String.to_integer
  defp get_agent(list), do: Enum.at(list, 5) |> get_agent_with_default
  defp get_agent_with_default("(null)"), do: "Unknown"
  defp get_agent_with_default(name) do
    if String.printable?(name) do
      name
    else
      "Unknown"
    end
  end
  defp get_latitude(list), do: Enum.at(list, 6) |> String.to_float
  defp get_longitude(list), do: Enum.at(list, 7) |> String.to_float
  defp get_city_name(list), do: Enum.at(list, 8) |> get_city_name_with_default
  defp get_city_name_with_default("(null)"), do: "Unknown"
  defp get_city_name_with_default(name), do: name
  defp get_continent_code(list), do: Enum.at(list, 9)
  defp get_country_code(list), do: Enum.at(list, 10)
  defp get_country_name(list), do: Enum.at(list, 11)

  defp useless_entry(entry) do
    entry.bytes == 0 || entry.status == 301
  end
end
