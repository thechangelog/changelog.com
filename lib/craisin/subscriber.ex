defmodule Craisin.Subscriber do
  import Craisin

  def details(list_id, email) do
    get("subscribers/#{list_id}?email=#{email}") |> local_handle
  end

  def subscribe(list_id, email, name) do
    fields = %{"EmailAddress" => email, "Name" => name,"Resubscribe" => true}
    post("subscribers/#{list_id}", Poison.encode!(fields)) |> local_handle
  end

  def unsubscribe(list_id, email) do
    fields = %{"EmailAddress" => email}
    post("subscribers/#{list_id}/unsubscribe", Poison.encode!(fields)) |> local_handle
  end

  defp local_handle({:ok, %HTTPoison.Response{body: %{"Code" => 1}}}), do: not_in_list()
  defp local_handle({:ok, %HTTPoison.Response{body: %{"Code" => 203}}}), do: not_in_list()
  defp local_handle(response), do: handle(response)

  defp not_in_list do
    %{"State" => "NotInList"}
  end
end
