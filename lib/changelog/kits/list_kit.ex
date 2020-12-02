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

  def exclude(list, things) when is_list(things), do: list -- things

  def exclude(list, %{id: id}), do: list |> Enum.reject(fn i -> i.id == id end)
  def exclude(list, nil), do: list
  def exclude(list, thing), do: list -- [thing]
end
