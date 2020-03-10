defmodule Changelog.ListKit do
  def compact(list) do
    list
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(&(&1 == ""))
  end

  def compact_join(list, delimiter \\ " ") do
    list
    |> compact()
    |> Enum.join(delimiter)
  end
end
