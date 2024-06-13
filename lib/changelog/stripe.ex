defmodule Changelog.Stripe do
  require Logger

  def customer(id) do
    case Stripe.Customer.retrieve(id) do
      {:ok, customer} ->
        customer

      {:error, error} ->
        Logger.info("Stripe error: #{inspect(error)}")
        nil
    end
  end

  def customers do
    Stream.unfold(nil, fn cursor ->
      params =
        case cursor do
          nil -> %{limit: 100}
          c -> %{limit: 100, starting_after: c}
        end

      case Stripe.Customer.list(params) do
        {:ok, %{data: []}} ->
          nil

        {:ok, %{data: customers}} ->
          next_cursor = customers |> List.last() |> Map.get(:id)
          {customers, next_cursor}

        {:error, _response} ->
          Logger.info("Stripe error")
          nil
      end
    end)
    |> Enum.to_list()
    |> List.flatten()
  end

  def subscription(id) do
    case Stripe.Subscription.retrieve(id) do
      {:ok, sub} ->
        sub

      {:error, error} ->
        Logger.info("Stripe error: #{inspect(error)}")
        nil
    end
  end

  def subscriptions(status \\ :all) do
    Stream.unfold(nil, fn cursor ->
      params =
        case cursor do
          nil -> %{limit: 100, status: status}
          c -> %{limit: 100, status: status, starting_after: c}
        end

      case Stripe.Subscription.list(params) do
        {:ok, %{data: []}} ->
          nil

        {:ok, %{data: subscriptions}} ->
          next_cursor = subscriptions |> List.last() |> Map.get(:id)
          {subscriptions, next_cursor}

        {:error, _response} ->
          Logger.info("Stripe error")
          nil
      end
    end)
    |> Enum.to_list()
    |> List.flatten()
  end
end
