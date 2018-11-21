defmodule Changelog.ListKit do
  def compact_join(list, delimiter \\ " ") do
    list
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(delimiter)
  end
end
