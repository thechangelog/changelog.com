defmodule ChangelogWeb.Plug.StripeWebhooks do
  @moduledoc """
  Validates origin of and extracts Stripe webhook event info
  """
  import Plug.Conn

  require Logger

  def init(config), do: config

  def call(%{request_path: "/stripe/event"} = conn, _) do
    try do
      signing_secret = Application.get_env(:stripity_stripe, :signing_secret)
      [stripe_signature] = get_req_header(conn, "stripe-signature")
      {:ok, body, _} = read_body(conn)
      {:ok, stripe_event} = Stripe.Webhook.construct_event(body, stripe_signature, signing_secret)
      assign(conn, :stripe_event, stripe_event)
    rescue
      error ->
        conn
        |> send_resp(:bad_request, inspect(error))
        |> halt()
    end

  end

  def call(conn, _), do: conn
end
