defmodule Craisin.Subscriber do
  import Craisin

  def details(list_id, email), do: "/subscribers/#{list_id}?email=#{email}" |> get |> local_handle
  def delete(list_id, email), do: "/subscribers/#{list_id}?email=#{email}" |> delete |> local_handle

  def subscribe(list_id, person, custom_fields \\ %{}) do
    fields = %{"EmailAddress" => person.email,
              "Name" => person.name,
              "Resubscribe" => true,
              "CustomFields" => mapped_custom_fields(custom_fields)}

    "/subscribers/#{list_id}" |> post(Poison.encode!(fields)) |> local_handle
  end

  def unsubscribe(list_id, email) do
    fields = %{"EmailAddress" => email}
    "/subscribers/#{list_id}/unsubscribe" |> post(Poison.encode!(fields)) |> local_handle
  end

  defp local_handle({:ok, %{body: %{"Code" => 1}}}), do: not_in_list()
  defp local_handle({:ok, %{body: %{"Code" => 203}}}), do: not_in_list()
  defp local_handle(response), do: handle(response)

  defp not_in_list, do: %{"State" => "NotInList"}

  defp mapped_custom_fields(custom_fields) do
    Enum.map(custom_fields, fn({k, v}) -> %{"Key" => k, "Value" => v} end)
  end
end
