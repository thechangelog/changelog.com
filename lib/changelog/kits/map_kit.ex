defmodule Changelog.MapKit do
  alias Changelog.StringKit
  @doc """
  Returns a map with all key/value pairs removed where the value was blank
  """
  def sans_blanks(map) do
    map
    |> Enum.reject(fn {_k, v} -> StringKit.blank?(v) end)
    |> Enum.reduce(%{}, fn {k, v}, acc ->  Map.put(acc, k, v) end)
  end
end
