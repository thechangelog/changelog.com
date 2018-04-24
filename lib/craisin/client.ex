defmodule Craisin.Client do
  import Craisin

  def campaigns(client_id), do: "/clients/#{client_id}/campaigns" |> get |> handle
  def lists(client_id), do: "/clients/#{client_id}/lists" |> get |> handle
end
