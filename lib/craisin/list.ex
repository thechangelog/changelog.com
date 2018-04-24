defmodule Craisin.List do
  import Craisin

  def active_subs(list_id), do: "/lists/#{list_id}/active" |> get_paginated

  def details(list_id), do: "/lists/#{list_id}" |> get |> handle
  def stats(list_id), do: "/lists/#{list_id}/stats" |> get |> handle

  defp get_paginated(path, page \\ 1, results \\ []) do
    response = "#{path}?page=#{page}"|> get |> handle
    results = [response["Results"] | results]

    if response["NumberOfPages"] > page do
      get_paginated(path, page + 1, results)
    else
      List.flatten(results)
    end
  end
end
