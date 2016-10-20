defmodule Changelog.Stats.Analyzer do
  def bytes(entries) do
    entries
    |> Enum.map(&(&1.bytes))
    |> Enum.sum
  end

  def downloads(_entries, 0), do: 0.0
  def downloads(entries, bytes_per_download) do
    (bytes(entries) / bytes_per_download) |> Float.round(2)
  end

  def downloads_by(entries, key, bytes_per_download) do
    entries
    |> Enum.group_by(&(Map.fetch!(&1, key)))
    |> Enum.map(fn({x, y}) -> {x, downloads(y, bytes_per_download)} end)
    |> Enum.sort(&(elem(&1, 1) > elem(&2, 1))) # most downloads on top
    |> Enum.reduce(%{}, fn({x, y}, acc) -> Map.put_new(acc, x, y) end)
  end

  def uniques_count(entries) do
    entries
    |> Enum.group_by(&(&1.ip))
    |> Map.keys
    |> length
  end
end
