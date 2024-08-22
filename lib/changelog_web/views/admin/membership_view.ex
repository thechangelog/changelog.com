defmodule ChangelogWeb.Admin.MembershipView do
  use ChangelogWeb, :admin_view

  alias ChangelogWeb.PersonView
  alias ChangelogWeb.Admin.SharedView

  def last_changed_at(membership) do
    if membership.updated_at > membership.inserted_at do
      membership.updated_at
    else
      membership.inserted_at
    end
  end

  def status_label(membership) do
    {text, color} =
      case membership.status do
        "active" -> {"Active", "green"}
        "unpaid" -> {"Unpaid", "red"}
        "past_due" -> {"Past due", "red"}
        "canceled" -> {"Canceled", "yellow"}
        "incomplete_expired" -> {"Expired", "gray"}
        other -> {String.capitalize(other), "gray"}
      end

    content_tag(:span, text, class: "ui tiny #{color} basic label")
  end

  def stripe_url(membership) do
    "https://dashboard.stripe.com/subscriptions/#{membership.subscription_id}"
  end

  def supercast_url(membership) do
    "https://changelog.supercast.com/dashboard/shared/subscribers/#{membership.supercast_id}"
  end
end
