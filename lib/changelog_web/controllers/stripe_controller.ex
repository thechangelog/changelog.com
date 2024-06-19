defmodule ChangelogWeb.StripeController do
  use ChangelogWeb, :controller

  alias Changelog.ObanWorkers

  def event(conn = %{assigns: %{stripe_event: stripe_event}}, _params) do
    case stripe_event.type do
      "customer.subscription.created" -> re_sync_memberships()
      "customer.subscription.deleted" -> re_sync_memberships()
      "customer.subscription.updated" -> re_sync_memberships()
      _otherwise -> :ok
    end

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "ok")
  end

  defp re_sync_memberships do
    Changelog.EventLog.insert("Syncing memberships due to webhook", "StripeController")
    ObanWorkers.MembershipSyncer.queue()
    :ok
  end
end
