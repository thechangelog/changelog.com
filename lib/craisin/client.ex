defmodule Craisin.Client do
  import Craisin

  def campaigns(client_id) do
    get("clients/#{client_id}/campaigns") |> handle
  end

  def lists(client_id) do
    get("clients/#{client_id}/lists") |> handle
  end
end
