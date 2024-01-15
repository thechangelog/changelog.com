defmodule Changelog.ObanWorkers.SmokeTester do
  @moduledoc """
  This Oban worker tests various API integrations to ensure they are still
  operational. If they are not, it sends a message to Sentry for review.
  """
  require Logger

  use Oban.Worker, queue: :scheduled

  @impl Oban.Worker
  def perform(_job) do
    test_shopify_integration()

    :ok
  end

  def test_shopify_integration do
    case Shopify.Product.count(Shopify.session()) do
      {:error, response} ->
        info = Map.take(response, [:code, :data])
        report("shopify_failure", info)
      {:ok, _response} -> :ok
    end
  end

  defp report(event_name, info) do
    if Mix.env() == :prod do
      Sentry.capture_message(event_name, extra: info)
    else
      Logger.info("#{event_name}: #{inspect(info)}")
    end
  end
end
