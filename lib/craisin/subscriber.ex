defmodule Craisin.Subscriber do
  import Craisin

  def details(list_id, email) do
    get("subscribers/#{list_id}?email=#{email}") |> local_handle
  end

  def subscribe(list_id, person, custom_fields \\ %{}) do
    fields = %{"EmailAddress" => person.email,
              "Name" => person.name,
              "Resubscribe" => true,
              "CustomFields" => mapped_custom_fields(custom_fields)}

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

  defp mapped_custom_fields(custom_fields) do
    Enum.map(custom_fields, fn({k, v}) -> %{"Key" => k, "Value" => v} end)
  end
end
