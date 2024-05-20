defmodule Craisin.Client do
  import Craisin

  @doc """
  Returns all transactional emails that bounced within the trackable period (90 days?)
  """
  def bounces(), do: messages_by_status("bounced")

  @doc """
  Returns all transactional emails marked as spam within the trackable period (90 days?)
  """
  def spam(), do: messages_by_status("spam")

  def messages_by_status(status, before_id \\ nil, accumulated \\ []) do
    response = get("/transactional/messages?status=#{status}&count=200&sentBeforeID=#{before_id}")

    case handle(response) do
      %{} ->
        accumulated
      [] ->
        accumulated
      list ->
        before_id = list |> List.last() |> Map.get("MessageID")
        messages_by_status(status, before_id, accumulated ++ list)
    end
  end

  def campaigns(client_id), do: "/clients/#{client_id}/campaigns" |> get() |> handle()
  def lists(client_id), do: "/clients/#{client_id}/lists" |> get() |> handle()

  def stats(group) do
    "/transactional/statistics?group=#{URI.encode(group)}" |> get() |> handle()
  end
end
