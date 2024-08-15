defmodule Changelog.ListKit do
  @doc """
  Returns the given `list` sans nils and empty strings
  """
  def compact(list) do
    list
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(&(&1 == ""))
  end

  @doc """
  Same as calling Enum.join/2 but first removes nils and empty strings
  """
  def compact_join(list, delimiter \\ " ") do
    list
    |> compact()
    |> Enum.join(delimiter)
  end

  @doc """
  Same as Enum.empty?/1 but all non-lists are also empty
  """
  def empty?(list) when is_list(list), do: Enum.empty?(list)
  def empty?(_), do: true

  @doc """
  Returns the given `list` sans the given `things`
  """
  def exclude(list, things) when is_list(things), do: list -- things

  def exclude(list, %{id: id}), do: list |> Enum.reject(fn i -> i.id == id end)
  def exclude(list, nil), do: list
  def exclude(list, thing), do: list -- [thing]

  @doc """
  Merges two lists and ensures only unique entries
  """
  def uniq_merge(list1, list2) do
    list1 |> Enum.concat(list2) |> Enum.uniq()
  end

  @doc """
  Returns whether or not two lists have any elements in common
  """
  def overlap?(one, two) when is_list(one) and is_list(two) do
    Enum.any?(one, fn(i) -> Enum.member?(two, i) end)
  end
end
