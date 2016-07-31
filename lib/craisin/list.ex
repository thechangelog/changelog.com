defmodule Craisin.List do
  import Craisin

  def details(list_id) do
    get("lists/#{list_id}") |> handle
  end

  def stats(list_id) do
    get("lists/#{list_id}/stats") |> handle
  end
end
