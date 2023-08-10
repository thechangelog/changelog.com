defmodule Craisin.Client do
  import Craisin

  @doc """
  Returns all transactional emails that bounced within the trackedable period (90 days?)
  """
  def bounces(before_id \\ nil, accumulated \\ []) do
    response = get("/transactional/messages?status=bounced&count=200&sentBeforeID=#{before_id}")

    case handle(response) do
      [] ->
        accumulated
      list ->
        before_id = list |> List.last() |> Map.get("MessageID")
        bounces(before_id, accumulated ++ list)
    end
  end

  def campaigns(client_id), do: "/clients/#{client_id}/campaigns" |> get() |> handle()
  def lists(client_id), do: "/clients/#{client_id}/lists" |> get() |> handle()
  def stats(group), do: "/transactional/statistics?group=#{URI.encode(group)}" |> get() |> handle()
end
